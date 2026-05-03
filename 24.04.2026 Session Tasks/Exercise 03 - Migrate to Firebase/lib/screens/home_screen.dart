// lib/screens/home_screen.dart
//
// The home screen, rewritten to use Firestore. The big architectural
// change from the SQLite version is the move from setState-after-fetch
// to StreamBuilder.
//
// SQLite version flow:
//   onChange → query DB → setState(_students = results) → ListView rebuilds
//
// Firestore version flow:
//   StreamBuilder subscribes to studentStream() once →
//   any change anywhere (this device, another device, the Firebase
//   console) pushes a fresh snapshot → builder runs → ListView rebuilds.
//
// This means the search filter is now slightly different. Instead of
// re-querying the database on each keystroke, I keep the full stream
// subscription and filter the snapshot client-side based on the search
// box. For a small dataset this is fine and gives instant responsiveness;
// for large datasets you'd switch back to a server-side query (and
// resubscribe to a filtered stream) on each search change.

import 'package:flutter/material.dart';
import '../firestore_service.dart';
import '../student.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _service = FirestoreService();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _seedOnce();
  }

  Future<void> _seedOnce() async {
    await _service.populateData();
    if (mounted) setState(() => _seeded = true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstCtrl,
              decoration: const InputDecoration(labelText: 'First name'),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: lastCtrl,
              decoration: const InputDecoration(labelText: 'Last name'),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _service.insertStudent(Student(
                id: '',
                firstName: firstCtrl.text.trim(),
                lastName: lastCtrl.text.trim(),
              ));
              if (ctx.mounted) Navigator.of(ctx).pop();
              // We don't need to refresh anything — the StreamBuilder
              // will pick up the new document automatically. That's the
              // whole point of the realtime subscription.
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Filter by last name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _service.studentStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_seeded) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Error: ${snapshot.error}',
                          textAlign: TextAlign.center),
                    ),
                  );
                }
                final all = snapshot.data ?? const <Student>[];
                final filtered = _searchQuery.isEmpty
                    ? all
                    : all
                        .where((s) => s.lastName
                            .toLowerCase()
                            .startsWith(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No students yet.\nTap + to add one.',
                        textAlign: TextAlign.center),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    return Dismissible(
                      key: Key(student.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child:
                            const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) =>
                          _service.deleteStudent(student.id),
                      child: ListTile(
                        title: Text(
                            '${student.firstName} ${student.lastName}'),
                        subtitle: Text('Doc: ${student.id}',
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailsScreen(student: student),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: 'Add student',
        child: const Icon(Icons.add),
      ),
    );
  }
}
