// lib/models/restaurant.dart
//
// Bundles the restaurant's identity (name, description, hours, etc.)
// into a single immutable object I can pass around the app.

import 'package:flutter/foundation.dart';

@immutable
class OpeningHours {
  final String day;     // "Monday", "Tue–Fri", etc.
  final String hours;   // "11:00 – 22:00", "Closed", etc.
  const OpeningHours(this.day, this.hours);
}

@immutable
class Restaurant {
  final String name;
  final String tagline;
  final String description;
  final String address;
  final String phone;
  final String heroImage;
  final List<OpeningHours> openingHours;

  const Restaurant({
    required this.name,
    required this.tagline,
    required this.description,
    required this.address,
    required this.phone,
    required this.heroImage,
    required this.openingHours,
  });
}
