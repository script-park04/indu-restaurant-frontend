import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const TagChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  factory TagChip.popular() {
    return const TagChip(
      label: 'Popular',
      backgroundColor: Color(0xFF4CAF50),
      textColor: Colors.white,
      icon: Icons.trending_up,
    );
  }

  factory TagChip.bestDeal() {
    return const TagChip(
      label: 'Best Deal',
      backgroundColor: Color(0xFFFF9800),
      textColor: Colors.white,
      icon: Icons.local_offer,
    );
  }

  factory TagChip.bestseller() {
    return const TagChip(
      label: 'Bestseller',
      backgroundColor: Color(0xFFFFD700),
      textColor: Color(0xFF000000),
      icon: Icons.star,
    );
  }

  factory TagChip.custom({
    required String label,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    return TagChip(
      label: label,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primaryContainer;
    final txtColor = textColor ?? Theme.of(context).colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: txtColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: txtColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget to display multiple tags
class TagList extends StatelessWidget {
  final List<String> tags;
  final bool isBestseller;

  const TagList({
    super.key,
    required this.tags,
    this.isBestseller = false,
  });

  @override
  Widget build(BuildContext context) {
    final allTags = <Widget>[];

    // Add bestseller tag if applicable
    if (isBestseller) {
      allTags.add(TagChip.bestseller());
    }

    // Add other tags
    for (final tag in tags) {
      if (tag == 'Popular') {
        allTags.add(TagChip.popular());
      } else if (tag == 'Best Deal of the Week' || tag == 'Best Deal') {
        allTags.add(TagChip.bestDeal());
      } else {
        allTags.add(TagChip.custom(label: tag));
      }
    }

    if (allTags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: allTags,
    );
  }
}
