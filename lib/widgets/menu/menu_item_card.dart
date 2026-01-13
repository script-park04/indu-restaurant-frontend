import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/menu_item.dart';
import '../../theme/app_theme.dart';
import '../../services/cart_service.dart';
import '../glass_container.dart';
import '../common/glass_button.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const MenuItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  final CartService _cartService = CartService();
  bool _isAdding = false;

  Future<void> _addToCart(bool isHalfPlate) async {
    setState(() => _isAdding = true);
    try {
      await _cartService.addToCart(
        itemId: widget.item.id,
        isHalfPlate: isHalfPlate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.item.name} added to cart'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      blur: 15,
      useBlur: false, // Optimisation: Cards in lists don't necessarily need blur
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Image Section ───
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: widget.item.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.item.imageUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 600,
                          placeholder: (context, url) => Container(
                            color: AppTheme.warmCream,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.warmCream,
                            child:
                                const Icon(Icons.restaurant, size: 48),
                          ),
                        )
                      : Container(
                          color: AppTheme.warmCream,
                          child: const Icon(Icons.restaurant, size: 48),
                        ),
                ),
              ),

              // Veg / Non-veg indicator
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.circle,
                    size: 12,
                    color: widget.item.isVegetarian
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),

              // Bestseller badge
              if (widget.item.isBestseller)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'BESTSELLER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Unavailable overlay
              if (!widget.item.isAvailable)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Center(
                      child: Text(
                        'UNAVAILABLE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ─── Content Section ───
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 1),

                if (widget.item.description != null)
                  SizedBox(
                    height: 26,
                    child: Text(
                      widget.item.description!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const SizedBox(height: 26),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Text(
                      '₹${widget.item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    if (widget.item.halfPlatePrice != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '/ ₹${widget.item.halfPlatePrice!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 6),

                if (widget.item.isAvailable)
                  widget.item.halfPlatePrice != null
                      ? Row(
                          children: [
                            Expanded(
                              child: GlassButton(
                                height: 32,
                                isSecondary: true,
                                onPressed: _isAdding
                                    ? null
                                    : () => _addToCart(true),
                                child: _isAdding
                                    ? const SizedBox(
                                        height: 12,
                                        width: 12,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Half',
                                        style: TextStyle(fontSize: 11),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GlassButton(
                                height: 32,
                                onPressed: _isAdding
                                    ? null
                                    : () => _addToCart(false),
                                child: const Text(
                                  'Full',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                        )
                      : GlassButton(
                          width: double.infinity,
                          height: 32,
                          onPressed: _isAdding
                              ? null
                              : () => _addToCart(false),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isAdding)
                                const SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                const Icon(Icons.add_shopping_cart,
                                    size: 14, color: Colors.white),
                              const SizedBox(width: 8),
                              const Text(
                                'Add to Cart',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
