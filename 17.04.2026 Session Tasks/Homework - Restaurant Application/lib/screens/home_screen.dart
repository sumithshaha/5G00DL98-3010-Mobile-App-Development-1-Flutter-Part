// lib/screens/home_screen.dart
//
// Home screen — restaurant info. The brief asks for "name, description,
// opening hours, etc." plus a way to navigate to the Menu.
//
// Layout I chose:
//   1. Hero image at the top (with the same asset-fallback pattern I've
//      been using since Unit 4, so the app runs without real photos).
//   2. Restaurant name in a Playfair Display title.
//   3. Tagline in italic.
//   4. Description paragraph.
//   5. Address + phone row.
//   6. Opening hours as a small table.
//   7. A big "View Menu" button at the bottom that pushes MenuScreen.
//
// Wrapped in SingleChildScrollView so it doesn't overflow on small phones
// or in landscape.

import 'package:flutter/material.dart';
import '../data/restaurant_data.dart';
import '../models/restaurant.dart';
import 'menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final r = auroraSpice; // Restaurant instance from data file.

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Hero image ───
              SizedBox(
                height: 220,
                child: Image.asset(
                  r.heroImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.tertiary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.restaurant,
                      size: 72,
                      color: cs.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),

              // ─── Body content ───
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      r.name,
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.tagline,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      r.description,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 28),

                    // ─── Contact row ───
                    _InfoRow(icon: Icons.place_outlined, text: r.address),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.phone_outlined, text: r.phone),

                    const SizedBox(height: 28),

                    // ─── Opening hours card ───
                    _OpeningHoursCard(hours: r.openingHours),

                    const SizedBox(height: 32),

                    // ─── CTA: View Menu ───
                    FilledButton.icon(
                      onPressed: () {
                        // Navigator.push to MenuScreen — the navigation
                        // pattern from Exercise 1.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MenuScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('View our menu'),
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

/// Small icon-plus-text row. Private to this file.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Opening hours rendered as a small table. Wrapped in a Card so it
/// stands apart visually from the rest of the body.
class _OpeningHoursCard extends StatelessWidget {
  final List<OpeningHours> hours;
  const _OpeningHoursCard({required this.hours});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text('Opening hours', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            // Each row is a Day–Hours pair.
            ...hours.map((h) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(h.day, style: theme.textTheme.bodyMedium),
                      Text(
                        h.hours,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
