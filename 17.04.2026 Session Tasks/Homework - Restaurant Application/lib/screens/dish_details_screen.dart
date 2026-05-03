// lib/screens/dish_details_screen.dart
//
// Third and final screen — detailed view of a single dish. I receive the
// Dish object via constructor (forward data passing from MenuScreen) and
// can pop back with a DishDetailsResult to tell the menu the user
// "ordered" something (return data passing).
//
// This is exactly the bidirectional flow Exercise 2 taught — just applied
// to a more realistic data type than a single string.

import 'package:flutter/material.dart';
import '../models/dish.dart';

/// Strongly-typed return value, instead of e.g. a bare bool. Even for a
/// homework toy app this is the right pattern — when you later want to
/// add fields (special instructions, quantity) you just extend the class.
class DishDetailsResult {
  final String dishName;
  final bool addedToCart;
  const DishDetailsResult({required this.dishName, required this.addedToCart});
}

class DishDetailsScreen extends StatelessWidget {
  final Dish dish;
  const DishDetailsScreen({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      // Using CustomScrollView + SliverAppBar to get the nice "image
      // collapses as you scroll" effect. Slightly fancier than a plain
      // Scaffold + AppBar, but well within this unit's scope.
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                dish.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Image.asset(
                dish.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cs.primaryContainer,
                  alignment: Alignment.center,
                  child: Text(
                    dish.category.emoji,
                    style: const TextStyle(fontSize: 96),
                  ),
                ),
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Price + tags row ───
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        dish.formattedPrice,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 6,
                        children: [
                          _Pill(
                            icon: Icons.timer_outlined,
                            label: '${dish.prepMinutes} min',
                            color: cs.tertiary,
                          ),
                          if (dish.isVegetarian)
                            _Pill(
                              icon: Icons.eco,
                              label: 'Veg',
                              color: Colors.green.shade700,
                            ),
                          if (dish.isSpicy)
                            _Pill(
                              icon: Icons.local_fire_department,
                              label: 'Spicy',
                              color: Colors.red.shade700,
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ─── Long description ───
                  Text('About this dish', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    dish.longDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // ─── Ingredients (only if present) ───
                  if (dish.ingredients.isNotEmpty) ...[
                    Text('Ingredients', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dish.ingredients
                          .map((i) => Chip(label: Text(i)))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ─── Category info ───
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          dish.category.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                )),
                            Text(dish.category.label,
                                style: theme.textTheme.titleMedium),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── Action buttons ───
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back to menu'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () {
                            // Pop with our typed result. The menu screen
                            // is awaiting this and will show a snackbar.
                            Navigator.pop(
                              context,
                              DishDetailsResult(
                                dishName: dish.name,
                                addedToCart: true,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add to order'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small rounded pill for time/diet info on the details screen.
class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
