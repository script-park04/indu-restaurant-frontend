import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/order.dart';
import '../../../models/user_profile.dart';
import '../../../models/address.dart';
import '../../../services/order_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/address_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/glass_container.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Order order;
  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final _orderService = OrderService();
  final _authService = AuthService();
  final _addressService = AddressService();

  late String _orderStatus;
  late String _paymentStatus;
  bool _updating = false;

  UserProfile? _customer;
  Address? _address;
  bool _loadingDetails = true;

  @override
  void initState() {
    super.initState();
    _orderStatus = widget.order.orderStatus;
    _paymentStatus = widget.order.paymentStatus;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _loadingDetails = true);
    final results = await Future.wait([
      _authService.getProfileById(widget.order.userId),
      if (widget.order.addressId != null)
        _addressService.getAddressById(widget.order.addressId!)
      else
        Future.value(null),
    ]);

    if (mounted) {
      setState(() {
        _customer = results[0] as UserProfile?;
        _address = results[1] as Address?;
        _loadingDetails = false;
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _updating = true);
    try {
      await _orderService.updateOrderStatus(widget.order.id, newStatus);
      if (mounted) {
        setState(() => _orderStatus = newStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  Future<void> _updatePaymentStatus(String newStatus) async {
    setState(() => _updating = true);
    try {
      await _orderService.updatePaymentStatus(widget.order.id, newStatus);
      if (mounted) {
        setState(() => _paymentStatus = newStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment status updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Order #${widget.order.id.substring(0, 8)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ Status Section
            _buildSection(
              title: 'Status Management',
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Order Status'),
                      const Spacer(),
                      if (_updating)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        DropdownButton<String>(
                          value: _orderStatus,
                          items: [
                            AppConstants.orderReceived,
                            AppConstants.orderPrepared,
                            AppConstants.orderOutForDelivery,
                            AppConstants.orderDelivered,
                            AppConstants.orderCancelled,
                          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => v != null ? _updateStatus(v) : null,
                        ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Text('Payment Status'),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _paymentStatus,
                        items: ['pending', 'completed', 'failed']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                            .toList(),
                        onChanged: (v) => v != null ? _updatePaymentStatus(v) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 👤 Customer Details
            _buildSection(
              title: 'Customer Details',
              child: _loadingDetails
                  ? const Center(child: CircularProgressIndicator())
                  : _customer == null
                      ? const Text('Customer info not found')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customer!.fullName ?? 'Unknown Customer',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(_customer!.phone ?? 'No phone'),
                            const SizedBox(height: 8),
                            if (_address != null) ...[
                              const Text(
                                'Delivery Address:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(_address!.label.toUpperCase(),
                                  style: const TextStyle(fontSize: 12, color: Colors.blue)),
                              Text(_address!.addressLine),
                              Text('${_address!.city}, ${_address!.state} - ${_address!.pincode}'),
                              if (_address!.landmark != null) Text('Landmark: ${_address!.landmark}'),
                            ] else
                              const Text('Address not found'),
                          ],
                        ),
            ),
            const SizedBox(height: 16),

            // 🍱 Order Items
            _buildSection(
              title: 'Order Items',
              child: Column(
                children: [
                  ...widget.order.items?.map((item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.itemName),
                            subtitle: Text('${item.quantity} x ₹${item.price}${item.isHalfPlate ? " (Half)" : ""}'),
                            trailing: Text('₹${item.totalPrice}'),
                          )) ??
                      [],
                  const Divider(),
                  _buildPriceRow('Subtotal', '₹${widget.order.totalAmount}'),
                  if (widget.order.discountAmount > 0)
                    _buildPriceRow('Discount', '-₹${widget.order.discountAmount}', color: Colors.green),
                  _buildPriceRow('Total', '₹${widget.order.finalAmount}', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 💳 Payment Info
            _buildSection(
              title: 'Payment Information',
              child: Column(
                children: [
                  _buildPriceRow('Method', widget.order.paymentMethod),
                  _buildPriceRow('Date', DateFormat('MMM d, yyyy h:mm a').format(widget.order.createdAt)),
                ],
              ),
            ),
            if (widget.order.specialInstructions?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              _buildSection(
                title: 'Special Instructions',
                child: Text(widget.order.specialInstructions!),
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: child,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
