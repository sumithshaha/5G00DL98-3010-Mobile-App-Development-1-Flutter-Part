// lib/main.dart
//
// Exercise 1 — extends the database_demo with a details screen and an
// Edit flow. I refactored the original main.dart's two screens (Home, Details)
// into separate files under lib/screens/ — this is the modularization pattern
// from Unit 6 applied here, and it's how I want to keep things organized
// once the project grows beyond two screens.

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Demo + Details',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(title: 'Database Demo'),
    );
  }
}
