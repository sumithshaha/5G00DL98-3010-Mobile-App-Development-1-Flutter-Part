// lib/main.dart
//
// Entry point. Following the modularization convention from Exercise 3:
// main.dart only sets up MaterialApp, theme, and points home at HomeScreen.
// Everything else lives in its own file.

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const RestaurantApp());

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora Spice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // follow OS setting
      home: const HomeScreen(),
    );
  }
}
