import 'package:flutter/material.dart';
import '../../../services/menu_service.dart';
import '../../../models/menu_item.dart';
import '../../../models/category.dart';
import '../../../widgets/glass_container.dart';

class AdminMenuEditScreen extends StatefulWidget {
  final MenuItem item;

  const AdminMenuEditScreen({super.key, required this.item});

  @override
  State<AdminMenuEditScreen> createState() => _AdminMenuEditScreenState();
}

class _AdminMenuEditScreenState extends State<AdminMenuEditScreen> {
  final _menuService = MenuService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _halfPriceCtrl;

  List<Category> _categories = [];
  String? _categoryId;

  late bool _isVeg;
  late bool _isBestseller;
  late bool _isAvailable;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    final i = widget.item;
    _nameCtrl = TextEditingController(text: i.name);
    _descCtrl = TextEditingController(text: i.description);
    _priceCtrl = TextEditingController(text: i.price.toString());
    _halfPriceCtrl =
        TextEditingController(text: i.halfPlatePrice?.toString() ?? '');
    _categoryId = i.categoryId;
    _isVeg = i.isVegetarian;
    _isBestseller = i.isBestseller;
    _isAvailable = i.isAvailable;

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
      await _menuService.updateMenuItem(widget.item.id, {
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
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _loading = true);
      await _menuService.deleteMenuItem(widget.item.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit Menu Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _loading ? null : _deleteItem,
          ),
        ],
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
                  items: _categories
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  decoration: const InputDecoration(labelText: 'Category'),
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
                      : const Text('Save Changes'),
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
