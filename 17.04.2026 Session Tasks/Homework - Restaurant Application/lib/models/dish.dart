// lib/models/dish.dart
//
// Plain data class for one dish. Immutable (all fields final) so I can
// hand the same instance to multiple widgets without anyone mutating it.

import 'package:flutter/foundation.dart';

enum DishCategory {
  starters('Starters', '🥗'),
  mains('Main Courses', '🍝'),
  desserts('Desserts', '🍰'),
  drinks('Drinks', '🥂');

  final String label;
  final String emoji;
  const DishCategory(this.label, this.emoji);
}

@immutable
class Dish {
  final String id;          // stable id, useful for keys later
  final String name;
  final String description; // short blurb shown in the menu list
  final String longDescription; // longer text for the details screen
  final double price;       // in EUR
  final DishCategory category;
  final String imageAsset;  // path under assets/images/
  final List<String> ingredients;
  final bool isVegetarian;
  final bool isSpicy;
  final int prepMinutes;    // how long it takes to prepare

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.longDescription,
    required this.price,
    required this.category,
    required this.imageAsset,
    this.ingredients = const [],
    this.isVegetarian = false,
    this.isSpicy = false,
    this.prepMinutes = 15,
  });

  /// Pretty-print the price with the EUR symbol. Locale-aware in a real app
  /// (NumberFormat.currency from package:intl), but for the homework we just
  /// hard-code Finnish/German formatting (€XX.XX).
  String get formattedPrice => '€${price.toStringAsFixed(2)}';
}
