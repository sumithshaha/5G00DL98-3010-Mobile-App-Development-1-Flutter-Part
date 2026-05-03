// Exercise 2 — Data Passing Between Screens
//
// Extends Exercise 1 with two-way data flow:
//   Home → Details : pass "Hello from Home Screen!" as a constructor arg
//   Details → Home : Details has a TextField, the user types a response,
//                    a button pops with that response as the result.
//
// The key Dart/Flutter concept here is that Navigator.push is generic and
// returns a Future<T?> — we await it, and whatever Details passed to
// Navigator.pop(value) becomes the resolved value of that Future.

import 'package:flutter/material.dart';

void main() => runApp(const DataPassingApp());

class DataPassingApp extends StatelessWidget {
  const DataPassingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise 2 — Data Passing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const HomeScreen(),
    );
  }
}

// ───────────────────────── HOME SCREEN ─────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _responseFromDetails;

  // Async because we await the result coming back from Details.
  Future<void> _openDetails() async {
    // Navigator.push<T> returns Future<T?>. T is the type Details will
    // pop with. We expect a String response.
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const DetailsScreen(
          messageFromHome: 'Hello from Home Screen!',
        ),
      ),
    );

    // result is null if the user pressed the system Back button without
    // submitting a response — handle both branches gracefully.
    if (!mounted) return;
    if (result != null && result.isNotEmpty) {
      setState(() => _responseFromDetails = result);
      // Snackbar feedback as the exercise spec mentions.
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
            // Display the latest result, persisted between navigations.
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

// ──────────────────────── DETAILS SCREEN ───────────────────────
class DetailsScreen extends StatefulWidget {
  // Forward data via the constructor — simplest, most type-safe pattern.
  final String messageFromHome;

  const DetailsScreen({super.key, required this.messageFromHome});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // TextEditingController is a mediator between TextField and our state.
  // Must be disposed to avoid the most common Flutter memory leak.
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendResponseBack() {
    final response = _controller.text.trim();
    if (response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type a response first.')),
      );
      return;
    }
    // Navigator.pop's second argument becomes the value of the Future
    // that Home is awaiting.
    Navigator.pop(context, response);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Display message received from Home.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Message from Home:', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(widget.messageFromHome, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 2. Input field for the response.
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Your response',
                hintText: 'Type something to send back…',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _sendResponseBack(),
            ),
            const SizedBox(height: 24),
            // 3. Send-back button.
            ElevatedButton.icon(
              onPressed: _sendResponseBack,
              icon: const Icon(Icons.send),
              label: const Text('Send response & go back'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel (back without response)'),
            ),
          ],
        ),
      ),
    );
  }
}
