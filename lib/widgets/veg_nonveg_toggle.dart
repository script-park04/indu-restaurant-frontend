import 'package:flutter/material.dart';

enum DietaryFilter { all, veg, nonVeg }

class VegNonVegToggle extends StatelessWidget {
  final DietaryFilter selectedFilter;
  final Function(DietaryFilter) onFilterChanged;

  const VegNonVegToggle({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterChip(
            context,
            label: 'All',
            filter: DietaryFilter.all,
            icon: Icons.restaurant_menu,
          ),
          _buildFilterChip(
            context,
            label: 'Veg',
            filter: DietaryFilter.veg,
            icon: Icons.circle,
            iconColor: Colors.green,
          ),
          _buildFilterChip(
            context,
            label: 'Non-Veg',
            filter: DietaryFilter.nonVeg,
            icon: Icons.circle,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required DietaryFilter filter,
    required IconData icon,
    Color? iconColor,
  }) {
    final isSelected = selectedFilter == filter;
    
    return InkWell(
      onTap: () => onFilterChanged(filter),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : (iconColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
