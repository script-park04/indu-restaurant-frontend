import 'package:flutter/material.dart';
import '../../../services/menu_service.dart';
import '../../../models/category.dart';
import '../../../widgets/glass_container.dart';

class AdminMenuAddScreen extends StatefulWidget {
  const AdminMenuAddScreen({super.key});

  @override
  State<AdminMenuAddScreen> createState() => _AdminMenuAddScreenState();
}

class _AdminMenuAddScreenState extends State<AdminMenuAddScreen> {
  final _menuService = MenuService();
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _halfPriceCtrl = TextEditingController();

  List<Category> _categories = [];
  String? _categoryId;

  bool _isVeg = true;
  bool _isBestseller = false;
  bool _isAvailable = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _menuService.getCategories();
    setState(() => _categories = cats);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _menuService.addMenuItem({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text),
        'half_plate_price':
            _halfPriceCtrl.text.isEmpty ? null : double.parse(_halfPriceCtrl.text),
        'category_id': _categoryId,
        'is_vegetarian': _isVeg,
        'is_bestseller': _isBestseller,
        'is_available': _isAvailable,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Add Menu Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(_nameCtrl, 'Item Name'),
                _field(_descCtrl, 'Description', maxLines: 3),
                Row(
                  children: [
                    Expanded(child: _field(_priceCtrl, 'Price (₹)', number: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_halfPriceCtrl, 'Half Plate (₹)', number: true)),
                  ],
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _categoryId,
                  hint: const Text('Category'),
                  items: _categories
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) =>
                      v == null ? 'Please select category' : null,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                ),

                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text('Vegetarian'),
                  value: _isVeg,
                  onChanged: (v) => setState(() => _isVeg = v),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Bestseller'),
                  value: _isBestseller,
                  onChanged: (v) => setState(() => _isBestseller = v),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Available'),
                  value: _isAvailable,
                  onChanged: (v) => setState(() => _isAvailable = v),
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Add Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool number = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: number ? TextInputType.number : null,
        decoration: InputDecoration(labelText: label),
        validator: (v) =>
            v == null || v.isEmpty ? 'Required field' : null,
      ),
    );
  }
}
