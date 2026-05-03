// Exercise 1 — Navigation with Navigator
//
// Two screens. Home has a button that pushes Details. Details has a button
// that pops back to Home. That's the entire spec from page 7 of Unit 6.
//
// I keep this in a single file deliberately — it's the "before" picture
// that the modularization exercise (Exercise 3) refactors into separate files.

import 'package:flutter/material.dart';

void main() => runApp(const NavigationApp());

class NavigationApp extends StatelessWidget {
  const NavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise 1 — Navigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      // `home` is the very first route the Navigator pushes onto its stack.
      home: const HomeScreen(),
    );
  }
}

// ───────────────────────── HOME SCREEN ─────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigator.push adds a new route on top of the stack.
            // MaterialPageRoute gives us the platform-correct slide animation.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DetailsScreen()),
            );
          },
          child: const Text('Go to Details Screen'),
        ),
      ),
    );
  }
}

// ──────────────────────── DETAILS SCREEN ───────────────────────
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigator.pop removes the topmost route from the stack,
            // returning us to whatever was beneath — in this case, Home.
            Navigator.pop(context);
          },
          child: const Text('Back to Home Screen'),
        ),
      ),
    );
  }
}
