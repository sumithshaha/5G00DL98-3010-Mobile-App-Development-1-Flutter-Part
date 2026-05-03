// lib/theme/app_theme.dart
//
// Custom theme — the brief explicitly lists this under Technical Requirements.
// I'm doing both: a custom color scheme (warm, earthy, restaurant-appropriate)
// and a custom typography stack via google_fonts.
//
// Typography choices:
//  - Display / titles: "Playfair Display" — a serif with high contrast that
//    feels editorial and food-magazine-y. Used for restaurant name, dish
//    names, section headers.
//  - Body: "Inter" — a clean modern sans-serif, easy to read at small sizes.
//
// Colors: a warm spice-inspired palette built around a deep terracotta
// seed color. ColorScheme.fromSeed generates a harmonious M3 palette from
// it, which I then customize selectively.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // The seed color drives the entire ColorScheme. I picked terracotta
  // (#B65431) — warm, food-y, neither aggressively red nor brown.
  static const Color _seedColor = Color(0xFFB65431);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      // Custom overrides — the auto-generated scheme is good but a few
      // tweaks make it feel more bespoke.
      primary: const Color(0xFFB65431),
      onPrimary: Colors.white,
      surface: const Color(0xFFFFF8F4),     // warm off-white background
      surfaceContainerHighest: const Color(0xFFF5E6D8),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return _buildTheme(colorScheme);
  }

  // ─────── shared theme builder ───────
  static ThemeData _buildTheme(ColorScheme cs) {
    // Base text theme uses Inter for everything, then I override the
    // larger styles to use Playfair Display so titles feel distinctive.
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: cs.brightness).textTheme,
    );
    final displayTextTheme = GoogleFonts.playfairDisplayTextTheme(
      ThemeData(brightness: cs.brightness).textTheme,
    );

    final textTheme = baseTextTheme.copyWith(
      displayLarge: displayTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: displayTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
      displaySmall: displayTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineLarge: displayTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: displayTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: displayTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: displayTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: cs.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: cs.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: cs.secondaryContainer,
        labelStyle: TextStyle(color: cs.onSecondaryContainer),
        side: BorderSide.none,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelLarge,
      ),
    );
  }
}
