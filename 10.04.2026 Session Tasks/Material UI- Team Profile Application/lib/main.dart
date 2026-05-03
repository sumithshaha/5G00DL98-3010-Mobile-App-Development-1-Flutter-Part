// lib/main.dart
//
// Entry point. Two jobs:
//   1. Initialize the app-wide Logger (carries over from page-45 exercise).
//   2. Hand control to the MaterialApp, whose only home is TeamProfileScreen.

import 'package:flutter/material.dart';
import 'data/team_data.dart';
import 'screens/team_profile_screen.dart';
import 'utils/app_logger.dart';

void main() {
  initAppLogger();
  log.i('Team Profile App starting up — team = ${teamAurora.name}, '
      'members = ${teamAurora.size}');
  runApp(const TeamProfileApp());
}

class TeamProfileApp extends StatelessWidget {
  const TeamProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Profile App',
      debugShowCheckedModeBanner: false,
      // Material 3 theme with a single seed color — the rest of the
      // ColorScheme (primary, secondary, tertiary, container surfaces, …)
      // is generated automatically and stays harmonious.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      // Dark mode comes for free — the system follows the OS setting.
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const TeamProfileScreen(team: teamAurora),
    );
  }
}
