// lib/screens/home_screen.dart
//
// Same logic as Ex2's home, but now in its own file. Notice the import
// is relative ("details_screen.dart") rather than fully qualified —
// for files inside the same package, relative imports are the Flutter
// convention.

import 'package:flutter/material.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _responseFromDetails;

  Future<void> _openDetails() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const DetailsScreen(
          messageFromHome: 'Hello from Home Screen!',
        ),
      ),
    );

    if (!mounted) return;
    if (result != null && result.isNotEmpty) {
      setState(() => _responseFromDetails = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details said: "$result"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _openDetails,
              child: const Text('Go to Details Screen'),
            ),
            const SizedBox(height: 32),
            if (_responseFromDetails != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Latest response from Details:',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"$_responseFromDetails"',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                'No response yet. Tap the button to send a message.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
