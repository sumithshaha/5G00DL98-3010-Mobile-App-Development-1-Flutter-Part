// lib/main.dart
//
// After modularization, main.dart's only job is to bootstrap the
// MaterialApp and point `home` at the first screen. No business logic,
// no widget definitions beyond the root MaterialApp wrapper.
//
// This is the convention the exercise on slide 16 of Unit 6 asks for:
//   "main.dart has just the main() and setting MaterialApp, Theme etc.
//    home refers to the HomeScreen()
//    All screens (Scaffolds) in their own file, e.g. home_screen.dart"

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const ModularApp());

class ModularApp extends StatelessWidget {
  const ModularApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise 3 — Modularized',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const HomeScreen(),
    );
  }
}
