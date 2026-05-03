// lib/main.dart
//
// Exercise 2 — HTTP demo + movie details screen.
//
// Same modularization pattern as Ex1: main.dart sets up MaterialApp and
// hands off to the home screen, which lives in its own file.

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

const _movieUri =
    'https://git.fiw.fhws.de/introduction-to-flutter-2025ss/unit-07-http-and-bloc/-/raw/329759b27023c59828215b51dd081b58c5c07d50/http_demo/movie_data.json';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(title: 'Movies', movieUri: _movieUri),
    );
  }
}
