// lib/screens/details_screen.dart
//
// Same UX as Exercise 1's details screen — view mode + edit mode +
// delete — but talking to Firestore instead of SQLite. The diff is small
// (just service class + id type), which is the architectural payoff of
// having a clean service layer.

import 'package:flutter/material.dart';
import '../firestore_service.dart';
import '../student.dart';

class DetailsScreen extends StatefulWidget {
  final Student student;
  const DetailsScreen({super.key, required this.student});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final FirestoreService _service = FirestoreService();
  late Student _student;
  bool _editing = false;
  bool _saving = false;
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

  void _enterEdit() {
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
    final updated = _student.copyWith(firstName: first, lastName: last);
    await _service.updateStudent(updated);
    if (!mounted) return;
    setState(() {
      _student = updated;
      _editing = false;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student updated in Firestore.')),
    );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete student?'),
        content: Text(
            'Permanently delete ${_student.firstName} ${_student.lastName}?'),
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
    await _service.deleteStudent(_student.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('Student Details'),
        actions: [
          if (!_editing)
            IconButton(icon: const Icon(Icons.edit), onPressed: _enterEdit),
          IconButton(
              icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _editing ? _editView(theme) : _readView(theme),
      ),
    );
  }

  Widget _readView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        _Row(
          icon: Icons.person,
          label: 'First name',
          value: _student.firstName,
        ),
        _Row(
          icon: Icons.badge_outlined,
          label: 'Last name',
          value: _student.lastName,
        ),
        _Row(
          icon: Icons.cloud_outlined,
          label: 'Firestore document ID',
          value: _student.id,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: _enterEdit,
          icon: const Icon(Icons.edit),
          label: const Text('Edit student'),
        ),
      ],
    );
  }

  Widget _editView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Editing ${_student.id}',
            style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
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
                            strokeWidth: 2, color: Colors.white))
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

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row(
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
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value,
                    style: theme.textTheme.titleMedium,
                    softWrap: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
