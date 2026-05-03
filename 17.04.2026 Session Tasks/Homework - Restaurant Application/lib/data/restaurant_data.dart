// lib/data/restaurant_data.dart
//
// Hardcoded restaurant info. The brief explicitly says "Data can be hardcoded"
// (Technical Requirements slide), so I'm not bothering with JSON loading or
// a backend. In a real app this would come from an HTTP call (next unit's
// topic) or a CMS.
//
// I made up a fictional Finnish-Bangladeshi fusion restaurant called
// "Aurora Spice" that fits the cross-border theme of our team. Replace the
// content with whatever your team picks.

import '../models/restaurant.dart';

const Restaurant auroraSpice = Restaurant(
  name: 'Aurora Spice',
  tagline: 'Where the Northern Lights meet South Asian flavour',
  description:
      'Aurora Spice is a small fusion bistro in the heart of Tampere, '
      'serving dishes that bridge Nordic ingredients with Bangladeshi spice '
      'traditions. Everything we cook is made from scratch each morning, '
      'sourced from Pirkanmaa farms whenever the season allows.',
  address: 'Hämeenkatu 14, 33100 Tampere, Finland',
  phone: '+358 40 123 4567',
  heroImage: 'assets/images/restaurant_hero.jpg',
  openingHours: [
    OpeningHours('Mon – Thu', '11:00 – 21:00'),
    OpeningHours('Fri – Sat', '11:00 – 23:00'),
    OpeningHours('Sun',       '12:00 – 20:00'),
  ],
);
