// lib/widgets/dish_list_tile.dart
//
// One row in the menu list. I made this its own widget rather than building
// it inline in the menu screen because (a) the brief asks for modularization,
// (b) the same tile renders the same way in every category tab, and (c) it's
// easier to test in isolation.
//
// Stateless — the dish doesn't change once displayed, and the tap behavior
// is delegated to the parent via onTap.

import 'package:flutter/material.dart';
import '../models/dish.dart';

class DishListTile extends StatelessWidget {
  final Dish dish;
  final VoidCallback onTap;

  const DishListTile({super.key, required this.dish, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      child: InkWell(
        // InkWell gives the Material ripple effect when tapping the card.
        // The borderRadius matches the Card's shape so the ripple is clipped.
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail (with fallback for missing assets).
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: Image.asset(
                    dish.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: cs.secondaryContainer,
                      alignment: Alignment.center,
                      child: Text(
                        dish.category.emoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Text block expands to fill remaining space.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dish.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dish.formattedPrice,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Diet tags row — only renders if there's something to show.
                    Wrap(
                      spacing: 6,
                      children: [
                        if (dish.isVegetarian)
                          _MiniTag(
                            icon: Icons.eco,
                            label: 'Veg',
                            color: Colors.green.shade700,
                          ),
                        if (dish.isSpicy)
                          _MiniTag(
                            icon: Icons.local_fire_department,
                            label: 'Spicy',
                            color: Colors.red.shade700,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small inline tag for dietary info. Private to this file because it's
/// only used here.
class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniTag({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
