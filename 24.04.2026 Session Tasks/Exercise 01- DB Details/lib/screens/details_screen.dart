// lib/screens/details_screen.dart
//
// The new screen for Exercise 1. It receives a Student via constructor
// (forward data passing), shows the details, and offers two actions:
//
//   1. The required behavior: just display the student's information.
//   2. The bonus: an Edit button that flips the view into edit mode with
//      two TextFields, then a Save button that calls
//      DatabaseService.updateStudent and pops back with `true` to signal
//      the home screen that it should refresh.
//
// I also added a Delete button while I was here — it's the one CRUD
// operation the home screen already exposes via swipe, but having it on
// the details screen too is a nicer UX (and demonstrates the full
// CREATE/READ/UPDATE/DELETE story this unit is teaching).
//
// The "currently editing?" decision is local to this screen — only this
// widget cares — so I'm using "Option 1: widget manages its own state"
// from Unit 3.

import 'package:flutter/material.dart';
import '../database_service.dart';
import '../student.dart';

class DetailsScreen extends StatefulWidget {
  final Student student;
  const DetailsScreen({super.key, required this.student});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final DatabaseService _db = DatabaseService();

  // The student we're showing — starts as widget.student, but if the
  // user edits and saves, _student gets replaced with the new instance.
  // Keeping this in state means the details view immediately reflects
  // edits without waiting for the home screen to refresh.
  late Student _student;

  bool _editing = false;
  bool _saving = false;
  // Tracks whether anything actually changed during this details session.
  // We use it to tell the home screen "yes, refresh" via Navigator.pop
  // regardless of how the user leaves (edit save, delete, back button,
  // or the FAB).
  bool _changed = false;

  // Controllers only used while editing. Created once, reused per edit
  // session, disposed when the State is destroyed.
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _firstCtrl = TextEditingController(text: _student.firstName);
    _lastCtrl = TextEditingController(text: _student.lastName);
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    // Reset the controllers from the current student each time we enter
    // edit mode — a previous Cancel shouldn't leak its in-progress text.
    _firstCtrl.text = _student.firstName;
    _lastCtrl.text = _student.lastName;
    setState(() => _editing = true);
  }

  void _cancelEdit() => setState(() => _editing = false);

  Future<void> _saveEdit() async {
    final first = _firstCtrl.text.trim();
    final last = _lastCtrl.text.trim();
    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both names are required.')),
      );
      return;
    }

    setState(() => _saving = true);
    final updated = Student(
      id: _student.id,
      firstName: first,
      lastName: last,
    );
    await _db.updateStudent(updated);
    if (!mounted) return;

    setState(() {
      _student = updated;   // local copy reflects the change immediately
      _editing = false;
      _saving = false;
      _changed = true;      // remember: home needs to refresh on pop
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student updated.')),
    );
  }

  Future<void> _deleteStudent() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete student?'),
        content: Text(
            'Are you sure you want to delete ${_student.firstName} '
            '${_student.lastName}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await _db.deleteStudent(_student.id);
    if (!mounted) return;

    // Pop with `true` so the home screen knows to refresh.
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // PopScope catches the OS back arrow and any other "pop" attempt so
    // we can always include the _changed flag. canPop:false intercepts
    // the pop; we then call Navigator.pop ourselves with the right value.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('Student Details'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: _enterEditMode,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _deleteStudent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _editing ? _buildEditView(theme) : _buildReadView(theme),
      ),
      // FAB pops back to the list. Using a button here too because the
      // system back arrow doesn't communicate "you're done viewing this".
      floatingActionButton: _editing
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to list'),
              onPressed: () => Navigator.pop(context, _changed),
            ),
      ),
    );
  }

  // ─────────── read-only view ───────────
  Widget _buildReadView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Big circular avatar with initials — purely decorative, but
        // makes the details screen feel like more than just a duplicate
        // of the list row.
        CircleAvatar(
          radius: 56,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            _initials(_student),
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _DetailRow(
          icon: Icons.person,
          label: 'First name',
          value: _student.firstName,
        ),
        _DetailRow(
          icon: Icons.badge_outlined,
          label: 'Last name',
          value: _student.lastName,
        ),
        _DetailRow(
          icon: Icons.tag,
          label: 'Database ID',
          value: _student.id.toString(),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: _enterEditMode,
          icon: const Icon(Icons.edit),
          label: const Text('Edit student'),
        ),
      ],
    );
  }

  // ─────────── edit view ───────────
  Widget _buildEditView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Editing student #${_student.id}',
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        TextField(
          controller: _firstCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'First name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _lastCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Last name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _saveEdit(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : _cancelEdit,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveEdit,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _initials(Student s) {
    final f = s.firstName.isNotEmpty ? s.firstName[0] : '';
    final l = s.lastName.isNotEmpty ? s.lastName[0] : '';
    return (f + l).toUpperCase();
  }
}

/// Small horizontal row with an icon, a label, and a value. Used in the
/// read-only view. Private to this file because it's purely a layout
/// helper.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
