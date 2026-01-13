import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../services/menu_service.dart';
import '../../models/menu_item.dart';
import '../../models/category.dart';
import '../../widgets/menu/menu_item_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/glass_button.dart';
import '../../widgets/common/glass_navigation_bar.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/veg_nonveg_toggle.dart';

class MenuScreen extends StatefulWidget {
  final String? categoryId;

  const MenuScreen({super.key, this.categoryId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MenuService _menuService = MenuService();

  List<MenuItem> _allItems = [];
  List<MenuItem> _filteredItems = [];
  List<Category> _categories = [];

  bool _isLoading = true;
  String? _error;

  String? _selectedCategoryId;
  String _sortBy = 'default';
  bool? _filterVeg;
  bool _filterHalfPlate = false;
  String _searchQuery = '';
  DietaryFilter _dietaryFilter = DietaryFilter.all;
  final ScrollController _scrollController = ScrollController();
  bool _isNavbarVisible = true;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      if (_isNavbarVisible) setState(() => _isNavbarVisible = false);
      return;
    }

    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isNavbarVisible) setState(() => _isNavbarVisible = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isNavbarVisible) setState(() => _isNavbarVisible = true);
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _menuService.getMenuItems(
        categoryId: _selectedCategoryId,
        isAvailable: true,
      );

      final categories = await _menuService.getCategories();

      _allItems = items;
      _categories = categories;

      _applyFiltersAndSort();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    var items = List<MenuItem>.from(_allItems);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        final nameLower = item.name.toLowerCase();
        final descLower = (item.description ?? '').toLowerCase();
        final queryLower = _searchQuery.toLowerCase();
        return nameLower.contains(queryLower) || descLower.contains(queryLower);
      }).toList();
    }

    // Apply dietary filter
    if (_dietaryFilter == DietaryFilter.veg) {
      items = items.where((item) => item.isVegetarian).toList();
    } else if (_dietaryFilter == DietaryFilter.nonVeg) {
      items = items.where((item) => !item.isVegetarian).toList();
    }

    items = _menuService.filterMenuItems(
      items,
      hasHalfPlate: _filterHalfPlate ? true : null,
      isVegetarian: _filterVeg,
    );

    items = _menuService.sortMenuItems(items, _sortBy);

    setState(() {
      _filteredItems = items;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outline.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sort By',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setSheetState) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSortChip('Default', 'default', setSheetState),
                        _buildSortChip('Price: Low to High', 'price_low', setSheetState),
                        _buildSortChip('Price: High to Low', 'price_high', setSheetState),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setSheetState) {
                    return Column(
                      children: [
                        _buildFilterToggle(
                          'Vegetarian Only',
                          Icons.eco_outlined,
                          _filterVeg == true,
                          (v) {
                            setSheetState(() {
                              _filterVeg = v ? true : null;
                            });
                            _applyFiltersAndSort();
                          },
                        ),
                        _buildFilterToggle(
                          'Half Plate Available',
                          Icons.restaurant_menu_outlined,
                          _filterHalfPlate,
                          (v) {
                            setSheetState(() {
                              _filterHalfPlate = v;
                            });
                            _applyFiltersAndSort();
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                GlassButton(
                  onPressed: () => Navigator.pop(context),
                  width: double.infinity,
                  child: const Text('Apply Selection'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortChip(String label, String value, StateSetter setSheetState) {
    final isSelected = _sortBy == value;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setSheetState(() => _sortBy = value);
          setState(() => _sortBy = value);
          _applyFiltersAndSort();
        }
      },
      selectedColor: colors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : colors.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colors.primary : colors.outline.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _buildFilterToggle(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.onSurface.withValues(alpha: 0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,

      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),

      body: _isLoading
          ? const LoadingIndicator(message: 'Loading menu...')
          : _error != null
              ? ErrorDisplay(
                  message: _error!,
                  onRetry: _loadData,
                )
              : Column(
                  children: [
                    if (_categories.isNotEmpty)
                      RepaintBoundary(
                        child: SizedBox(
                          height: 56,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _categories.length + 1,
                            itemBuilder: (context, index) {
                              final isAll = index == 0;
                              final category =
                                  isAll ? null : _categories[index - 1];
                    
                              final selected = isAll
                                  ? _selectedCategoryId == null
                                  : _selectedCategoryId == category!.id;
                    
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    isAll ? 'All' : category!.name,
                                    style: TextStyle(
                                      color: selected ? Colors.white : null,
                                    ),
                                  ),
                                  selected: selected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedCategoryId =
                                          isAll ? null : category!.id;
                                    });
                                    _loadData();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Search and dietary filter
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          SearchBarWidget(
                            onSearch: (query) {
                              setState(() => _searchQuery = query);
                              _applyFiltersAndSort();
                            },
                            hintText: 'Search menu items...',
                          ),
                          const SizedBox(height: 12),
                          VegNonVegToggle(
                            selectedFilter: _dietaryFilter,
                            onFilterChanged: (filter) {
                              setState(() => _dietaryFilter = filter);
                              _applyFiltersAndSort();
                            },
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _filteredItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No items found for "$_searchQuery"'
                                        : 'No items found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RepaintBoundary(
                              child: GridView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.68,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredItems[index];
                                  return MenuItemCard(
                                    item: item,
                                    onTap: () =>
                                        context.go('/item/${item.id}'),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),

      bottomNavigationBar: GlassNavigationBar(
        currentIndex: 1,
        isVisible: _isNavbarVisible,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              break;
            case 2:
              context.go('/orders');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}
