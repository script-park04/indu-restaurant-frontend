import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/menu_service.dart';
import '../../services/cart_service.dart';
import '../../models/menu_item.dart';
import '../../models/category.dart';
import '../../widgets/menu/menu_item_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/common/glass_navigation_bar.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _menuService = MenuService();
  final _cartService = CartService();
  final ScrollController _scrollController = ScrollController();

  List<MenuItem> _bestsellers = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;
  int _cartItemCount = 0;
  bool _isNavbarVisible = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCartCount();
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
      final bestsellers = await _menuService.getBestsellers();
      final categories = await _menuService.getCategories();

      setState(() {
        _bestsellers = bestsellers;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCartCount() async {
    try {
      final count = await _cartService.getCartItemCount();
      setState(() => _cartItemCount = count);
    } catch (_) {}
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,

      // ─── Minimal Meta-style AppBar
      appBar: AppBar(
        title: const Text('Indu'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => context.push('/cart'),
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_cartItemCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      extendBody: true,
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading menu...')
          : _error != null
              ? ErrorDisplay(message: _error!, onRetry: _loadData)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Meta / Ollama-style hero panel
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: GlassContainer(
                            borderRadius: 28,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Indu Multicuisine',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryRed,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Authentic Indo-Chinese flavors, crafted fresh.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ─── Categories (quiet glass chips)
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              'Categories',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          RepaintBoundary(
                            child: SizedBox(
                              height: 112,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  final category = _categories[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(right: 12),
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      onTap: () => context.push(
                                          '/menu?category=${category.id}'),
                                      child: SizedBox(
                                        width: 100,
                                        child: GlassContainer(
                                          borderRadius: 20,
                                          padding: EdgeInsets.zero,
                                          blur: 8,
                                          useBlur: false, // Disable blur for small, frequent list items
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 68,
                                                width: 100,
                                                child: category.imageUrl != null
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius.vertical(
                                                                top:
                                                                    Radius.circular(
                                                                        20)),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              category.imageUrl!,
                                                          fit: BoxFit.cover,
                                                          width:
                                                              double.infinity,
                                                          placeholder: (_, __) =>
                                                              const Icon(
                                                            Icons.restaurant,
                                                            color: Colors.white,
                                                            size: 32,
                                                          ),
                                                          errorWidget:
                                                              (_, __, ___) =>
                                                                  const Icon(
                                                            Icons.restaurant,
                                                            color: Colors.white,
                                                            size: 32,
                                                          ),
                                                        ),
                                                      )
                                                    : const Icon(
                                                        Icons.restaurant,
                                                        color: Colors.white,
                                                        size: 32,
                                                      ),
                                              ),
                                              SizedBox(
                                                height: 36,
                                                child: Center(
                                                  child: Text(
                                                    category.name,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    maxLines: 2,
                                                    textAlign:
                                                        TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        // ─── Bestsellers (Meta-style grid)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bestsellers',
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () => context.push('/menu'),
                                child: const Text('Browse'),
                              ),
                            ],
                          ),
                        ),

                        if (_bestsellers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text('No bestsellers available'),
                            ),
                          )
                        else
                          RepaintBoundary(
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.68,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: _bestsellers.length,
                              itemBuilder: (context, index) {
                                return MenuItemCard(
                                  item: _bestsellers[index],
                                  onTap: () => context.push(
                                      '/item/${_bestsellers[index].id}'),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

      // ─── Quiet Meta-style bottom dock
      bottomNavigationBar: GlassNavigationBar(
        currentIndex: 0,
        isVisible: _isNavbarVisible,
        onTap: (index) {
          switch (index) {
            case 0:
              // already on Home
              break;
            case 1:
              context.go('/menu');
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
