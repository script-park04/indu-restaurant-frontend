import 'package:flutter/material.dart';
import '../../services/menu_service.dart';
import '../../services/cart_service.dart';
import '../../models/menu_item.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/glass_button.dart';
import '../../widgets/glass_container.dart';
import '../../theme/app_theme.dart';

class FoodDetailScreen extends StatefulWidget {
  final String itemId;

  const FoodDetailScreen({super.key, required this.itemId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final _menuService = MenuService();
  final _cartService = CartService();

  MenuItem? _item;
  bool _isLoading = true;
  bool _isAddingToCart = false;
  String? _error;
  
  int _quantity = 1;
  bool _isHalfPlate = false;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    try {
      final item = await _menuService.getMenuItemById(widget.itemId);
      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_item == null) return;

    setState(() => _isAddingToCart = true);
    try {
      await _cartService.addToCart(
        itemId: _item!.id,
        quantity: _quantity,
        isHalfPlate: _isHalfPlate,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_item!.name} added to cart'),
            backgroundColor: AppTheme.primaryRed,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to cart or handled by parent
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: LoadingIndicator(message: 'Loading deliciousness...')),
      );
    }

    if (_error != null || _item == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(_error ?? 'Item not found', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 24),
              GlassButton(
                onPressed: _loadItem,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final currentPrice = _isHalfPlate && _item!.halfPlatePrice != null
        ? _item!.halfPlatePrice!
        : _item!.price;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Hero Image Section
                Stack(
                  children: [
                    Hero(
                      tag: 'item-${_item!.id}',
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(_item!.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (_item!.isVegetarian)
                                _buildBadge(Icons.circle, Colors.green, 'VEG')
                              else
                                _buildBadge(Icons.change_history, Colors.red, 'NON-VEG'),
                              if (_item!.isBestseller) ...[
                                const SizedBox(width: 8),
                                _buildBadge(Icons.star, Colors.orange, 'BESTSELLER'),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _item!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Price and Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${currentPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.primaryRed,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildQuantitySelector(),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ─── Plate Size (if available)
                      if (_item!.halfPlatePrice != null) ...[
                        const Text(
                          'Select Portion',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildChoiceChip('Full Plate', !_isHalfPlate, () {
                              setState(() => _isHalfPlate = false);
                            }),
                            const SizedBox(width: 12),
                            _buildChoiceChip('Half Plate', _isHalfPlate, () {
                              setState(() => _isHalfPlate = true);
                            }),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ─── Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _item!.description ?? 'No description available for this delicious item.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 120), // Bottom padding for button
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Sticky Add to Cart Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: GlassButton(
              onPressed: _isAddingToCart ? null : _addToCart,
              height: 60,
              child: _isAddingToCart
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'Add to Cart · ₹${(currentPrice * _quantity).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color, String label) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 8,
      color: color.withValues(alpha: 0.2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      borderRadius: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityBtn(Icons.remove, () {
            if (_quantity > 1) setState(() => _quantity--);
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _quantity.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildQuantityBtn(Icons.add, () {
            setState(() => _quantity++);
          }),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 12),
          borderRadius: 12,
          color: isSelected ? AppTheme.primaryRed.withValues(alpha: 0.3) : null,
          border: Border.all(
            color: isSelected ? AppTheme.primaryRed : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
