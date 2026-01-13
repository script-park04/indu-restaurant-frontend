import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../services/loyalty_service.dart';
import '../../models/cart_item.dart';
import '../../models/address.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/glass_button.dart';
import '../../widgets/loyalty_balance_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();
  final _orderService = OrderService();
  final _loyaltyService = LoyaltyService();
  
  List<CartItem> _cartItems = [];
  Map<String, dynamic>? _orderPreview;
  Map<String, dynamic>? _loyaltySummary;
  bool _isLoading = true;
  String? _error;
  double _loyaltyPointsToRedeem = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadLoyaltySummary();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _cartService.getCartItems();
      setState(() {
        _cartItems = items;
      });
      
      // Load order preview after cart items are loaded
      await _loadOrderPreview();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOrderPreview() async {
    if (_cartItems.isEmpty) {
      setState(() => _orderPreview = null);
      return;
    }

    try {
      final preview = await _orderService.calculateOrderPreview(
        loyaltyPointsToRedeem: _loyaltyPointsToRedeem > 0 ? _loyaltyPointsToRedeem : null,
      );
      setState(() => _orderPreview = preview);
    } catch (e) {
      // Preview calculation failed, continue without it
      setState(() => _orderPreview = null);
    }
  }

  Future<void> _loadLoyaltySummary() async {
    try {
      final summary = await _loyaltyService.getLoyaltySummary();
      setState(() => _loyaltySummary = summary);
    } catch (e) {
      // Loyalty summary failed, continue without it
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    try {
      await _cartService.updateQuantity(item.id, newQuantity);
      _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantity: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      await _cartService.removeFromCart(item.id);
      _loadCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.menuItem?.name} removed from cart'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove item: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _showLoyaltyRedemptionDialog() {
    if (_loyaltySummary == null) return;
    
    final availablePoints = _loyaltySummary!['available_points'] as double;
    if (availablePoints < 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum ₹250 loyalty points required for redemption'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Loyalty Points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available: ₹${availablePoints.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            const Text('Redemption range: ₹250 - ₹500'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Points to redeem',
                prefixText: '₹',
              ),
              onChanged: (value) {
                _loyaltyPointsToRedeem = double.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadOrderPreview();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: () async {
                await _cartService.clearCart();
                _loadCart();
              },
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading cart...')
          : _error != null
              ? ErrorDisplay(message: _error!, onRetry: _loadCart)
              : _cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            size: 100,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          GlassButton(
                            width: 200,
                            onPressed: () => context.push('/menu'),
                            child: const Text('Browse Menu'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              final menuItem = item.menuItem;
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: menuItem?.imageUrl != null
                                              ? CachedNetworkImage(
                                                  imageUrl: menuItem!.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Container(
                                                    color: AppTheme.warmCream,
                                                  ),
                                                  errorWidget: (context, url, error) => Container(
                                                    color: AppTheme.warmCream,
                                                    child: const Icon(Icons.restaurant),
                                                  ),
                                                )
                                              : Container(
                                                  color: AppTheme.warmCream,
                                                  child: const Icon(Icons.restaurant),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              menuItem?.name ?? 'Unknown',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.isHalfPlate ? 'Half Plate' : 'Full Plate',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '₹${item.itemPrice.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryRed,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Quantity controls
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove_circle_outline),
                                                onPressed: () => _updateQuantity(item, item.quantity - 1),
                                                color: AppTheme.primaryRed,
                                              ),
                                              Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add_circle_outline),
                                                onPressed: () => _updateQuantity(item, item.quantity + 1),
                                                color: AppTheme.primaryRed,
                                              ),
                                            ],
                                          ),
                                          TextButton.icon(
                                            onPressed: () => _removeItem(item),
                                            icon: const Icon(Icons.delete_outline, size: 16),
                                            label: const Text('Remove', style: TextStyle(fontSize: 12)),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppTheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Bottom summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: Column(
                              children: [
                                // Loyalty balance card
                                if (_loyaltySummary != null && (_loyaltySummary!['available_points'] as num) > 0) ...[
                                  LoyaltyBalanceCard(
                                    totalPoints: _loyaltySummary!['total_points'],
                                    availablePoints: _loyaltySummary!['available_points'],
                                    timeUntilAvailable: _loyaltySummary!['time_until_available'],
                                    onTap: _showLoyaltyRedemptionDialog,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                
                                // Order preview breakdown
                                if (_orderPreview != null) ...[
                                  _buildPriceRow(
                                    'Subtotal',
                                    _orderPreview!['total_amount'],
                                  ),
                                  if ((_orderPreview!['discount_amount'] as num) > 0) ...[
                                    const SizedBox(height: 8),
                                    _buildPriceRow(
                                      'Discount (${_orderPreview!['discount_description']})',
                                      -(_orderPreview!['discount_amount'] as double),
                                      color: Colors.green,
                                    ),
                                  ],
                                  if ((_orderPreview!['loyalty_discount'] as num) > 0) ...[
                                    const SizedBox(height: 8),
                                    _buildPriceRow(
                                      'Loyalty Points',
                                      -(_orderPreview!['loyalty_discount'] as double),
                                      color: Colors.green,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  _buildPriceRow(
                                    'Delivery Charge',
                                    _orderPreview!['delivery_charge'],
                                    subtitle: _orderPreview!['delivery_charge'] == 0
                                        ? 'Free delivery!'
                                        : null,
                                  ),
                                  const Divider(height: 24),
                                  _buildPriceRow(
                                    'Total',
                                    _orderPreview!['final_amount'],
                                    isBold: true,
                                    fontSize: 20,
                                  ),
                                  if ((_orderPreview!['loyalty_points_to_earn'] as num) > 0) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.stars, size: 16, color: Colors.amber),
                                        const SizedBox(width: 6),
                                        Text(
                                          'You will earn ${_orderPreview!['loyalty_points_to_earn'].toStringAsFixed(0)} points',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ] else ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Subtotal',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '₹${_subtotal.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 16),
                                GlassButton(
                                  onPressed: () async {
                                    final result = await context.push<Address>(
                                      '/location-selection',
                                      extra: {'isSelectionMode': true},
                                    );
                                    if (result != null && mounted) {
                                      // Passed address back, go to checkout
                                      context.push('/checkout', extra: {
                                        'address': result,
                                        'orderPreview': _orderPreview!,
                                      });
                                    }
                                  },
                                  child: const Text('Proceed to Checkout'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    Color? color,
    bool isBold = false,
    double fontSize = 14,
    String? subtitle,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              '${amount < 0 ? '-' : ''}₹${amount.abs().toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: color ?? (isBold ? AppTheme.primaryRed : null),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
