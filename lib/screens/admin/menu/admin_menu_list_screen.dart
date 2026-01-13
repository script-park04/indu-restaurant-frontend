import 'package:flutter/material.dart';
import '../../../services/menu_service.dart';
import '../../../models/menu_item.dart';
import '../../../models/category.dart';
import '../../../widgets/glass_container.dart';
import 'admin_menu_edit_screen.dart';
import 'admin_menu_add_screen.dart';

class AdminMenuListScreen extends StatefulWidget {
  const AdminMenuListScreen({super.key});

  @override
  State<AdminMenuListScreen> createState() => _AdminMenuListScreenState();
}

class _AdminMenuListScreenState extends State<AdminMenuListScreen> {
  final _menuService = MenuService();
  final _searchCtrl = TextEditingController();

  List<MenuItem> _items = [];
  List<Category> _categories = [];

  String _query = '';
  String? _categoryId;
  bool? _vegOnly;
  bool _bestsellerOnly = false;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final items = await _menuService.getMenuItems();
    final categories = await _menuService.getCategories();

    setState(() {
      _items = items;
      _categories = categories;
      _loading = false;
    });
  }

  List<MenuItem> get _filteredItems {
    return _items.where((item) {
      final matchesSearch =
          item.name.toLowerCase().contains(_query.toLowerCase());

      final matchesVeg =
          _vegOnly == null || item.isVegetarian == _vegOnly;

      final matchesBestseller =
          !_bestsellerOnly || item.isBestseller;

      final matchesCategory =
          _categoryId == null || item.categoryId == _categoryId;

      return matchesSearch &&
          matchesVeg &&
          matchesBestseller &&
          matchesCategory;
    }).toList();
  }

  Future<void> _deleteItem(MenuItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to delete ${item.name}?'),
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
      await _menuService.deleteMenuItem(item.id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Admin · Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Item',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminMenuAddScreen(),
              ),
            ).then((_) => _loadData()),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔍 Search & Filters in a Glass Container
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search menu items...',
                          ),
                          onChanged: (v) =>
                              setState(() => _query = v),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('Veg'),
                                selected: _vegOnly == true,
                                onSelected: (v) =>
                                    setState(() => _vegOnly = v ? true : null),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Non-Veg'),
                                selected: _vegOnly == false,
                                onSelected: (v) =>
                                    setState(() => _vegOnly = v ? false : null),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Bestseller'),
                                selected: _bestsellerOnly,
                                onSelected: (v) =>
                                    setState(() => _bestsellerOnly = v),
                              ),
                              const SizedBox(width: 12),
                              DropdownButton<String?>(
                                value: _categoryId,
                                hint: const Text('Category'),
                                underline: const SizedBox(),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All Categories'),
                                  ),
                                  ..._categories.map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _categoryId = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 📋 List
                Expanded(
                  child: _filteredItems.isEmpty
                      ? const Center(
                          child: Text('No items found'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filteredItems.length,
                          itemBuilder: (_, i) {
                            final item = _filteredItems[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: GlassContainer(
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  title: Text(item.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      '₹${item.price} • ${item.isVegetarian ? "Veg" : "Non-Veg"}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AdminMenuEditScreen(item: item),
                                          ),
                                        ).then((_) => _loadData()),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => _deleteItem(item),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
