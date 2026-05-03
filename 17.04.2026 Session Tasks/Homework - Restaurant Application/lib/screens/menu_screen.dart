// lib/screens/menu_screen.dart
//
// Menu screen — categorized list of dishes. The brief lists four categories
// (starters, mains, desserts, drinks), which maps perfectly onto a TabBar
// with four tabs. Unit 6 slides 19-21 explicitly cover this widget combo
// (DefaultTabController + TabBar + TabBarView), so this is the most
// "course-aligned" choice.
//
// Each tab renders a ListView.builder over the dishes in that category.
// I'm using ListView.builder (not just a Column or static map) because
// slide 26 specifically explains when to choose builder over map: dynamic
// content, performance, lazy construction. Even though the menu is short
// here, builder is the right pedagogical answer.

import 'package:flutter/material.dart';
import '../data/menu_data.dart';
import '../models/dish.dart';
import '../widgets/dish_list_tile.dart';
import 'dish_details_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController is the simplest way to wire a TabBar to a
    // TabBarView — it creates and owns the controller for us. If we
    // needed to listen to tab changes programmatically I'd switch to
    // an explicit TabController in a StatefulWidget.
    return DefaultTabController(
      length: DishCategory.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menu'),
          // The bottom property is where TabBar normally lives — it sits
          // just under the AppBar title.
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: DishCategory.values.map((cat) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji),
                    const SizedBox(width: 6),
                    Text(cat.label),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: DishCategory.values.map((cat) {
            return _CategoryListView(category: cat);
          }).toList(),
        ),
      ),
    );
  }
}

/// One tab's content — a scrollable list of dishes in `category`.
/// Pulled out as its own widget for clarity; could equally be inline.
class _CategoryListView extends StatelessWidget {
  final DishCategory category;
  const _CategoryListView({required this.category});

  @override
  Widget build(BuildContext context) {
    final dishes = dishesIn(category);
    if (dishes.isEmpty) {
      return Center(
        child: Text(
          'Nothing here yet.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dishes.length,
      itemBuilder: (context, i) {
        final dish = dishes[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DishListTile(
            dish: dish,
            onTap: () => _openDetails(context, dish),
          ),
        );
      },
    );
  }

  /// Push the details screen with the tapped dish, then handle whatever
  /// the details screen pops back. This is the data-passing pattern from
  /// Exercise 2: forward via constructor, await result, react to result.
  Future<void> _openDetails(BuildContext context, Dish dish) async {
    final result = await Navigator.push<DishDetailsResult>(
      context,
      MaterialPageRoute(builder: (_) => DishDetailsScreen(dish: dish)),
    );

    if (!context.mounted) return;
    if (result != null && result.addedToCart) {
      // Show a confirmation when the user "ordered" something.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.dishName} added to your order'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
