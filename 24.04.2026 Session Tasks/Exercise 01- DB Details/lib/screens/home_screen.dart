// lib/screens/home_screen.dart
//
// The original main.dart's home page, lifted into its own file. Two changes
// from the starter code:
//   1. Tapping a ListTile now navigates to DetailsScreen via Navigator.push,
//      passing the Student object via the constructor.
//   2. After returning from DetailsScreen, we refresh the list — the user
//      may have edited the student in the details screen, so the displayed
//      data could be stale.
//
// Everything else (search, swipe-to-delete, add-via-dialog) is unchanged.

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../database_service.dart';
import '../student.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final textController = TextEditingController();
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _populateData();
  }

  void _populateData() async {
    await _databaseService.populateData();
    _refreshList();
  }

  void _refreshList() async {
    final results = await _databaseService.students();
    setState(() => _students = results);
  }

  void _onChanged(String input) async {
    final results = await _databaseService.findByName(textController.text);
    for (var v in results) {
      Logger().i(v.firstName);
    }
    setState(() => _students = results);
  }

  // Tapping a row pushes the details screen, then awaits the result.
  // If DetailsScreen popped with `true`, the student was edited or
  // deleted, so we refresh.
  Future<void> _openDetails(Student student) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetailsScreen(student: student)),
    );
    if (!mounted) return;
    if (changed == true) _onChanged(textController.text);
  }

  void _showAddDialog() {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First name'),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last name'),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _databaseService.insertStudent(Student(
                id: 0,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
              ));
              if (context.mounted) Navigator.of(context).pop();
              _onChanged(textController.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
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
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: textController,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search by last name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Dismissible(
                  key: Key(student.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await _databaseService.deleteStudent(student.id);
                    _onChanged(textController.text);
                  },
                  child: ListTile(
                    title: Text('${student.firstName} ${student.lastName}'),
                    subtitle: Text('ID: ${student.id}'),
                    // The trailing chevron is a UI affordance — it tells
                    // users this row is tappable and leads somewhere.
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openDetails(student),
                  ),
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
