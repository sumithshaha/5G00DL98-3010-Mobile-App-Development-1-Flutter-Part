// lib/main.dart
//
// Portfolio task entry point. The interesting wiring is the
// MovieRepository — created once at the root and passed to the home
// screen via constructor. Could equally be a top-level singleton like
// the database services in earlier exercises; constructor injection is
// just slightly more testable.

import 'package:flutter/material.dart';

import 'data/movie_repository.dart';
import 'screens/home_screen.dart';

const _movieUri =
    'https://git.fiw.fhws.de/introduction-to-flutter-2025ss/unit-07-http-and-bloc/-/raw/329759b27023c59828215b51dd081b58c5c07d50/http_demo/movie_data.json';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Database',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(
        title: 'Movies',
        repository: MovieRepository(movieUri: _movieUri),
      ),
    );
  }
}
