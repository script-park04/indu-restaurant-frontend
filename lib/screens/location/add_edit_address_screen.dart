import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/address.dart';
import '../../services/address_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common/glass_button.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? address;

  const AddEditAddressScreen({
    super.key,
    this.address,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressService = AddressService();
  
  late TextEditingController _labelController;
  late TextEditingController _addressLineController;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? 'Home');
    _addressLineController = TextEditingController(text: widget.address?.addressLine ?? '');
    _landmarkController = TextEditingController(text: widget.address?.landmark ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _pincodeController = TextEditingController(text: widget.address?.pincode ?? '');
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressLineController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newAddress = Address(
        id: widget.address?.id ?? '', // ID handled by DB for new items
        userId: '', // Handled by service
        label: _labelController.text.trim(),
        addressLine: _addressLineController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        isDefault: _isDefault,
        createdAt: DateTime.now(),
      );

      if (widget.address == null) {
        await _addressService.addAddress(newAddress);
      } else {
        await _addressService.updateAddress(newAddress);
      }

      if (mounted) {
        context.pop(true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving address: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add New Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Label Chips
              Text('Label', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: ['Home', 'Work', 'Other'].map((label) {
                  final isSelected = _labelController.text == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _labelController.text = label);
                        }
                      },
                      selectedColor: AppTheme.primaryRed.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryRed : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (!['Home', 'Work'].contains(_labelController.text)) 
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextFormField(
                    controller: _labelController,
                    decoration: const InputDecoration(labelText: 'Custom Label (e.g., My Apartment)'),
                    validator: (value) => Validators.validateRequired(value, 'Label'),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressLineController,
                decoration: const InputDecoration(
                  labelText: 'House No, Building, Street Area',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                maxLines: 2,
                validator: (value) => Validators.validateRequired(value, 'Address'),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _landmarkController,
                decoration: const InputDecoration(
                  labelText: 'Landmark (Optional) / Comments',
                  hintText: 'Near Park / Gate code 1234',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator: (value) => Validators.validateRequired(value, 'City'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: 'State'),
                      validator: (value) => Validators.validateRequired(value, 'State'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(
                  labelText: 'Pincode',
                  prefixIcon: Icon(Icons.pin_drop_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val != null && val.length < 6 ? 'Invalid Pincode' : null,
              ),

              const SizedBox(height: 24),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as Default Address'),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
                 activeThumbColor: AppTheme.primaryRed,
              ),

              const SizedBox(height: 32),

              GlassButton(
                onPressed: _isLoading ? null : _saveAddress,
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEditing ? 'Update Address' : 'Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
