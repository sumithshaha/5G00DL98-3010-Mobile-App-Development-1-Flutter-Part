import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Lifecycle Demo',
      home: HostPage(),
    );
  }
}

/// HostPage owns a counter and a "show child" toggle.
/// Changing the counter forces the LifecycleWidget's parent to rebuild
/// with new configuration — that triggers didUpdateWidget on the child.
/// Toggling the boolean inserts/removes the widget — that triggers
/// initState / deactivate / dispose.
class HostPage extends StatefulWidget {
  const HostPage({super.key});

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  int _label = 0;
  bool _showChild = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lifecycle Demo')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Wrap in a Theme so we can demonstrate didChangeDependencies
          // by changing inherited data.
          Theme(
            data: ThemeData(
              primaryColor: _label.isEven ? Colors.blue : Colors.red,
            ),
            child: _showChild
                ? LifecycleWidget(label: _label)
                : const Text('Child is gone'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _label++),
            child: const Text('Change label (triggers didUpdateWidget)'),
          ),
          ElevatedButton(
            onPressed: () => setState(() => _showChild = !_showChild),
            child: Text(_showChild ? 'Remove child' : 'Insert child'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SecondPage()),
            ),
            child: const Text('Push new route'),
          ),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Second Page')),
        body: const Center(child: Text('Pop back to see deactivate/dispose')),
      );
}

/// THE STAR OF THE SHOW: every lifecycle method is overridden and logged.
class LifecycleWidget extends StatefulWidget {
  const LifecycleWidget({super.key, required this.label});

  final int label;

  @override
  State<LifecycleWidget> createState() {
    debugPrint('🟢 1. createState()  — StatefulWidget builds its State object');
    return _LifecycleWidgetState();
  }
}

class _LifecycleWidgetState extends State<LifecycleWidget> {
  int _internalCounter = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 2. initState()    — State inserted in tree, one-time setup');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint(
        '🟢 3. didChangeDependencies() — inherited data is now available '
        '(or has changed)');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🟢 4. build()        — rendering with widget.label=${widget.label}, '
        '_internalCounter=$_internalCounter');
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Label from parent: ${widget.label}'),
            Text('Internal counter: $_internalCounter'),
            TextButton(
              onPressed: () => setState(() {
                _internalCounter++;
                debugPrint('   ↳ setState() called — schedules a rebuild');
              }),
              child: const Text('Bump internal counter (setState)'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LifecycleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('🟢 5. didUpdateWidget() — parent rebuilt with new config: '
        '${oldWidget.label} → ${widget.label}');
  }

  @override
  void reassemble() {
    super.reassemble();
    debugPrint('🟢 *. reassemble()   — hot reload happened');
  }

  @override
  void deactivate() {
    debugPrint(
        '🟢 6. deactivate()   — State removed from tree (might come back)');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint(
        '🟢 7. dispose()      — State permanently destroyed, free resources');
    super.dispose();
  }
}
