import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/order_service.dart';
import '../../../models/order.dart';
import '../../../utils/constants.dart';
import '../../../widgets/glass_container.dart';
import 'admin_order_detail_screen.dart';

class AdminOrdersListScreen extends StatefulWidget {
  const AdminOrdersListScreen({super.key});

  @override
  State<AdminOrdersListScreen> createState() => _AdminOrdersListScreenState();
}

class _AdminOrdersListScreenState extends State<AdminOrdersListScreen> {
  final _orderService = OrderService();
  String _query = '';
  String? _statusFilter;

  final List<String> _statuses = [
    'All',
    AppConstants.orderReceived,
    AppConstants.orderPrepared,
    AppConstants.orderOutForDelivery,
    AppConstants.orderDelivered,
    AppConstants.orderCancelled,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Admin · Orders'),
      ),
      body: Column(
        children: [
          // 🔍 Filters & Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: GlassContainer(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by Order ID...',
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statuses.map((status) {
                        final isSelected = (_statusFilter == null && status == 'All') ||
                            (_statusFilter == status);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _statusFilter = status == 'All' ? null : status;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 📋 Real-time Order List
          Expanded(
            child: StreamBuilder<List<Order>>(
              stream: _orderService.listenToAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data!;
                final filteredOrders = orders.where((order) {
                  final matchesQuery = order.id.toLowerCase().contains(_query.toLowerCase());
                  final matchesStatus = _statusFilter == null || order.orderStatus == _statusFilter;
                  return matchesQuery && matchesStatus;
                }).toList();

                if (filteredOrders.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: GlassContainer(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminOrderDetailScreen(order: order),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                'Order #${order.id.substring(0, 8)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              _getStatusBadge(order.orderStatus),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${order.items?.length ?? 0} items • ₹${order.finalAmount}'),
                              Text(
                                DateFormat('MMM d, h:mm a').format(order.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == AppConstants.orderReceived) color = Colors.blue;
    if (status == AppConstants.orderPrepared) color = Colors.orange;
    if (status == AppConstants.orderOutForDelivery) color = Colors.purple;
    if (status == AppConstants.orderDelivered) color = Colors.green;
    if (status == AppConstants.orderCancelled) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

