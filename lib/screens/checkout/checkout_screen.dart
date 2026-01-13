import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/address.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass_button.dart';
import '../../services/coupon_service.dart';
import '../../models/coupon.dart';
import '../../widgets/common/loading_indicator.dart';

class CheckoutScreen extends StatefulWidget {
  final Address address;
  final Map<String, dynamic> orderPreview;

  const CheckoutScreen({
    super.key, 
    required this.address,
    required this.orderPreview,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _orderService = OrderService();
  final _couponService = CouponService();
  bool _isLoading = false;
  String _selectedPaymentMethod = 'UPI'; // Default to UPI
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();
  Coupon? _appliedCoupon;
  Map<String, dynamic>? _updatedPreview;
  bool _isValidatingCoupon = false;

  Future<void> _placeOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For now, loyalty points are handled in preview or need to be passed.
      // Assuming OrderPreview contains logic or we pass what was calculated.
      // But OrderService.createOrder recalculates. 
      // Ideally we should pass loyaltyPointsToRedeem if used.
      
      // Extract loyalty points from preview if available (hacky but works for now)
      double? loyaltyPointsUsed;
      if (widget.orderPreview['loyalty_discount'] != null && 
          (widget.orderPreview['loyalty_discount'] as num) > 0) {
        loyaltyPointsUsed = (widget.orderPreview['loyalty_discount'] as num).toDouble();
      }

      await _orderService.createOrder(
        addressId: widget.address.id,
        paymentMethod: _selectedPaymentMethod,
        loyaltyPointsToRedeem: loyaltyPointsUsed,
        appliedCoupon: _appliedCoupon,
        specialInstructions: _instructionsController.text.trim().isEmpty 
            ? null 
            : _instructionsController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        // Navigate to Orders or Home
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Order Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isValidatingCoupon = true);

    try {
      final subtotal = widget.orderPreview['total_amount'] as double;
      final coupon = await _couponService.validateCoupon(code, subtotal);
      
      // Recalculate preview with coupon
      final loyaltyToRedeem = widget.orderPreview['loyalty_discount'] as double?;
      final preview = await _orderService.calculateOrderPreview(
        loyaltyPointsToRedeem: loyaltyToRedeem,
        appliedCoupon: coupon,
      );

      setState(() {
        _appliedCoupon = coupon;
        _updatedPreview = preview;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon applied!'), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isValidatingCoupon = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _updatedPreview ?? widget.orderPreview;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isLoading 
        ? const LoadingIndicator(message: 'Placing your order...')
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Address Section
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primaryRed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.address.label,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.address.fullAddress,
                              style: const TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Payment Method Section
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('UPI (Google Pay / PhonePe)'),
                      value: 'UPI',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                      activeColor: AppTheme.primaryRed,
                    ),
                    RadioListTile<String>(
                      title: const Text('Cash on Delivery'),
                      value: 'COD',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                      activeColor: AppTheme.primaryRed,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Special Instructions
              const Text(
                'Special Instructions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  hintText: 'e.g., "Don\'t ring the bell"',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Coupon Code Section
              const Text(
                'Coupon Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          decoration: const InputDecoration(
                            hintText: 'Enter code',
                            border: InputBorder.none,
                            filled: false,
                          ),
                          enabled: !_isValidatingCoupon && _appliedCoupon == null,
                        ),
                      ),
                      if (_appliedCoupon != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _appliedCoupon = null;
                              _updatedPreview = null;
                              _couponController.clear();
                            });
                          },
                          child: const Text('Remove', style: TextStyle(color: Colors.red)),
                        )
                      else
                        _isValidatingCoupon
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : TextButton(
                              onPressed: _applyCoupon,
                              child: const Text('Apply'),
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Order Summary
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSummaryRow('Subtotal', preview['total_amount']),
                      if ((preview['discount_amount'] as num) > 0)
                        _buildSummaryRow(
                          'Automatic Discount', 
                          -(preview['discount_amount'] as num).toDouble(),
                          isGreen: true
                        ),
                      if (preview['coupon_discount'] != null && (preview['coupon_discount'] as num) > 0)
                        _buildSummaryRow(
                          'Coupon (${_appliedCoupon?.code})', 
                          -(preview['coupon_discount'] as num).toDouble(),
                          isGreen: true
                        ),
                      if ((preview['loyalty_discount'] as num) > 0)
                        _buildSummaryRow(
                          'Loyalty Points',
                          -(preview['loyalty_discount'] as num).toDouble(),
                          isGreen: true
                        ),
                      _buildSummaryRow('Delivery Charge', preview['delivery_charge']),
                      const Divider(height: 24),
                      _buildSummaryRow(
                        'Total', 
                        preview['final_amount'],
                        isBold: true,
                        fontSize: 18
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              GlassButton(
                onPressed: _placeOrder,
                child: const Text('Place Order'),
              ),
              const SizedBox(height: 32),
            ],
          ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, dynamic amount, {bool isBold = false, double fontSize = 14, bool isGreen = false}) {
    final double value = (amount is int) ? amount.toDouble() : amount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
            '${value < 0 ? "-" : ""}₹${value.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isGreen ? Colors.green : (isBold ? AppTheme.primaryRed : null),
            ),
          ),
        ],
      ),
    );
  }
}
