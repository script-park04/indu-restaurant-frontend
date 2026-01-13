import 'package:flutter/material.dart';
import '../../../services/config_service.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/loading_indicator.dart';

class AdminDiscountConfigScreen extends StatefulWidget {
  const AdminDiscountConfigScreen({super.key});

  @override
  State<AdminDiscountConfigScreen> createState() => _AdminDiscountConfigScreenState();
}

class _AdminDiscountConfigScreenState extends State<AdminDiscountConfigScreen> {
  final _configService = ConfigService();
  final _formKey = GlobalKey<FormState>();
  
  final _firstOrderCtrl = TextEditingController();
  final _secondOrderCtrl = TextEditingController();
  final _subsequentCtrl = TextEditingController();
  final _minAmountCtrl = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    final config = await _configService.getAppConfig();
    
    setState(() {
      _firstOrderCtrl.text = config.firstOrderDiscountPercent.toString();
      _secondOrderCtrl.text = config.secondOrderDiscountPercent.toString();
      _subsequentCtrl.text = config.subsequentOrderDiscountPercent.toString();
      _minAmountCtrl.text = config.secondOrderMinAmount.toString();
      _isLoading = false;
    });
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _configService.updateDiscountConfig(
        firstOrderPercent: double.parse(_firstOrderCtrl.text),
        secondOrderPercent: double.parse(_secondOrderCtrl.text),
        subsequentOrderPercent: double.parse(_subsequentCtrl.text),
        secondOrderMinAmount: double.parse(_minAmountCtrl.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Discount configuration saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Configuration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading configuration...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order-based Discounts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure automatic discount percentages for customer orders',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 24),
                    
                    TextFormField(
                      controller: _firstOrderCtrl,
                      decoration: const InputDecoration(
                        labelText: 'First Order Discount (%)',
                        hintText: 'e.g., 10',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null || val < 0 || val > 100) {
                          return 'Enter a value between 0 and 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _secondOrderCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Second Order Discount (%)',
                        hintText: 'e.g., 10',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null || val < 0 || val > 100) {
                          return 'Enter a value between 0 and 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _minAmountCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Min Amount for 2nd Order Discount (₹)',
                        hintText: 'e.g., 500',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null || val < 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _subsequentCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Subsequent Orders Discount (%)',
                        hintText: 'e.g., 5',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(),
                        helperText: 'Applied from 3rd order onwards',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null || val < 0 || val > 100) {
                          return 'Enter a value between 0 and 100';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    GlassButton(
                      onPressed: _isSaving ? null : _saveConfig,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save Configuration'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _firstOrderCtrl.dispose();
    _secondOrderCtrl.dispose();
    _subsequentCtrl.dispose();
    _minAmountCtrl.dispose();
    super.dispose();
  }
}
