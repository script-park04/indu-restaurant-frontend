import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/address.dart';
import '../../services/address_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass_button.dart';

class LocationSelectionScreen extends StatefulWidget {
  final bool isSelectionMode;

  const LocationSelectionScreen({
    super.key,
    this.isSelectionMode = false,
  });

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final _addressService = AddressService();
  late Future<List<Address>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    setState(() {
      _addressesFuture = _addressService.getUserAddresses();
    });
  }

  Future<void> _deleteAddress(String id) async {
    try {
      await _addressService.deleteAddress(id);
      _loadAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting address: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
      ),
      body: FutureBuilder<List<Address>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.location_off_outlined, size: 80, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                   const SizedBox(height: 16),
                   const Text(
                     'No addresses found',
                     style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
                   ),
                   const SizedBox(height: 24),
                   GlassButton(
                     width: 200,
                     onPressed: () async {
                       final result = await context.push('/location/add');
                       if (result == true) _loadAddresses();
                     },
                     child: const Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.add, color: Colors.white),
                         SizedBox(width: 8),
                         Text('Add New Address'),
                       ],
                     ),
                   ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: address.isDefault 
                      ? const BorderSide(color: AppTheme.primaryRed, width: 1.5)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () async {
                    if (widget.isSelectionMode) {
                      context.pop(address);
                    } else {
                      final result = await context.push('/location/edit', extra: address);
                      if (result == true) _loadAddresses();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              address.label.toLowerCase() == 'work' ? Icons.work : Icons.home,
                              color: AppTheme.primaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              address.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (address.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRed.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryRed,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final result = await context.push('/location/edit', extra: address);
                                  if (result == true) _loadAddresses();
                                } else if (value == 'delete') {
                                  _deleteAddress(address.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          address.fullAddress,
                          style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
                        ),
                        if (address.landmark != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Landmark/Note: ${address.landmark}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/location/add');
          if (result == true) _loadAddresses();
        },
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
