import 'package:flutter/material.dart';
import '../../../services/delivery_service.dart';
import '../../../models/service_radius.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/loading_indicator.dart';

class AdminServiceRadiusScreen extends StatefulWidget {
  const AdminServiceRadiusScreen({super.key});

  @override
  State<AdminServiceRadiusScreen> createState() => _AdminServiceRadiusScreenState();
}

class _AdminServiceRadiusScreenState extends State<AdminServiceRadiusScreen> {
  final _deliveryService = DeliveryService();
  List<ServiceRadius> _serviceAreas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServiceAreas();
  }

  Future<void> _loadServiceAreas() async {
    setState(() => _isLoading = true);
    
    final areas = await _deliveryService.getAllServiceAreas();
    
    setState(() {
      _serviceAreas = areas;
      _isLoading = false;
    });
  }

  void _showAddDialog() {
    final pincodeCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final distanceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Service Area'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pincodeCtrl,
                decoration: const InputDecoration(
                  labelText: 'PIN Code *',
                  hintText: 'e.g., 560001',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  hintText: 'e.g., Bangalore',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: areaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Area (Optional)',
                  hintText: 'e.g., MG Road',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: distanceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Distance (km) *',
                  hintText: '3.0 - 6.0',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (pincodeCtrl.text.isEmpty ||
                  cityCtrl.text.isEmpty ||
                  distanceCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }

              final distance = double.tryParse(distanceCtrl.text);
              if (distance == null || distance < 3.0 || distance > 6.0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Distance must be between 3 and 6 km')),
                );
                return;
              }

              try {
                await _deliveryService.addServiceArea(
                  pincode: pincodeCtrl.text,
                  city: cityCtrl.text,
                  area: areaCtrl.text.isEmpty ? null : areaCtrl.text,
                  distanceKm: distance,
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                _loadServiceAreas();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Service area added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleArea(ServiceRadius area) async {
    try {
      await _deliveryService.toggleServiceArea(area.id, !area.isActive);
      _loadServiceAreas();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(area.isActive ? 'Area deactivated' : 'Area activated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteArea(ServiceRadius area) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service Area'),
        content: Text('Delete ${area.pincode} - ${area.city}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _deliveryService.deleteServiceArea(area.id);
        _loadServiceAreas();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service area deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Radius'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading service areas...')
          : _serviceAreas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No service areas configured',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GlassButton(
                        onPressed: _showAddDialog,
                        child: const Text('Add Service Area'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _serviceAreas.length,
                  itemBuilder: (context, index) {
                    final area = _serviceAreas[index];
                    final isValid = area.isWithinServiceRange;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isValid
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isValid ? Icons.check_circle : Icons.warning,
                            color: isValid ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          '${area.pincode} - ${area.city}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (area.area != null) Text(area.area!),
                            Text(
                              '${area.distanceKm} km',
                              style: TextStyle(
                                color: isValid ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: area.isActive,
                              onChanged: (_) => _toggleArea(area),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteArea(area),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
