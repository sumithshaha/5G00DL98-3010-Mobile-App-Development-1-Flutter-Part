// lib/screens/details_screen.dart
//
// Identical logic to Ex2's details, just isolated. The TextEditingController
// lives here too, since it's specific to this screen's TextField.

import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  final String messageFromHome;

  const DetailsScreen({super.key, required this.messageFromHome});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Message from Home:',
                        style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(widget.messageFromHome,
                        style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
