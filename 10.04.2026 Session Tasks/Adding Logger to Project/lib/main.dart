// logger_demo/lib/main.dart
//
// A small self-contained Flutter app whose only purpose is to demonstrate
// the `logger` package (https://pub.dev/packages/logger) end-to-end:
//
//   1. Logger is added in pubspec.yaml as a dependency.
//   2. A *single* Logger instance is created at app start (top of main.dart).
//   3. Debug / Info / Warning / Error / Fatal calls are exercised from both
//      app startup and a button tap, so you can watch them stream into the
//      Logging tab of DartDevTools.
//
// To run:
//    flutter pub get
//    flutter run
//
// To see the logs:
//    Open DevTools (the URL prints in the console when you start `flutter run`)
//    Switch to the "Logging" tab.
//    Tap the buttons in the app — entries appear immediately.

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// A single, app-wide Logger instance.
///
/// I keep this top-level so any file can `import 'main.dart'` (or, in a real
/// project, a dedicated `app_logger.dart`) and call `log.d(...)` without
/// having to wire it through constructors. It's the closest thing to
/// `print()` that still respects log levels and pretty formatting.
late final Logger log;

void main() {
  // Initialize the logger BEFORE runApp so that anything that logs during
  // widget construction (initState, etc.) hits a real Logger instead of
  // crashing on a null reference.
  log = Logger(
    // PrettyPrinter gives you the nice boxed output with emoji, colors,
    // and a stack trace excerpt. There are other printers (SimplePrinter,
    // LogfmtPrinter) — PrettyPrinter is the right default for development.
    printer: PrettyPrinter(
      methodCount: 2,        // how many stack frames to show on every log
      errorMethodCount: 8,   // how many to show specifically on .e() calls
      lineLength: 80,        // wrap width
      colors: true,          // ANSI colors in the console
      printEmojis: true,     // 🐛 ℹ️ ⚠️ ⛔ in the prefix
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    // In release builds we don't want verbose logs polluting production.
    // `kDebugMode` is true only in `flutter run` / debug builds.
    level: kDebugMode ? Level.trace : Level.warning,
  );

  // First log line of the app — this proves initialization worked.
  log.i('Logger initialized. App is starting up…');

  runApp(const LoggerDemoApp());
}

class LoggerDemoApp extends StatelessWidget {
  const LoggerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logger Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoggerDemoHome(),
    );
  }
}

class LoggerDemoHome extends StatefulWidget {
  const LoggerDemoHome({super.key});
  @override
  State<LoggerDemoHome> createState() => _LoggerDemoHomeState();
}

class _LoggerDemoHomeState extends State<LoggerDemoHome> {
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    // Lifecycle log — useful for spotting unintended rebuilds later.
    log.d('LoggerDemoHome.initState — building UI');
  }

  // ───────────────────────── log emitters ─────────────────────────
  // Each button maps to one Logger method so you can see the difference
  // in DevTools' Logging tab clearly.

  void _emitTrace() {
    log.t('TRACE — fine-grained event at tap #$_tapCount '
        '(t = ${DateTime.now().toIso8601String()})');
  }

  void _emitDebug() {
    log.d('DEBUG — _tapCount is now $_tapCount; this is the level you '
        'usually want during development');
  }

  void _emitInfo() {
    log.i('INFO — user successfully pressed the Info button');
  }

  void _emitWarning() {
    log.w('WARNING — counter is getting high ($_tapCount). '
        'Nothing is broken, but something looks off.');
  }

  void _emitError() {
    // Real-world pattern: catch an exception, then log it together with
    // its stack trace so DevTools can show you exactly where it came from.
    try {
      // Deliberately blow up so we have a real stack trace.
      final List<int> empty = <int>[];
      empty.first; // throws StateError
    } catch (e, stack) {
      log.e('ERROR — caught while doing the risky thing',
          error: e, stackTrace: stack);
    }
  }

  void _emitFatal() {
    log.f('FATAL — the app is in a state we cannot recover from. '
        'In production this is the level you wire to crash reporting '
        '(Sentry, Crashlytics, …).');
  }
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logger Demo'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How to view these logs',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Run with `flutter run` — this prints a "Dart VM '
                      'service is listening on http://127.0.0.1:…" URL.\n'
                      '2. Hit "d" in that terminal (or click the link in '
                      'the IDE) to open DartDevTools.\n'
                      '3. Switch to the "Logging" tab.\n'
                      '4. Tap the buttons below — entries appear live.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Taps: $_tapCount', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _btn('Trace',    Colors.grey,    _emitTrace),
                _btn('Debug',    Colors.blue,    _emitDebug),
                _btn('Info',     Colors.green,   _emitInfo),
                _btn('Warning',  Colors.orange,  _emitWarning),
                _btn('Error',    Colors.red,     _emitError),
                _btn('Fatal',    Colors.purple,  _emitFatal),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _tapCount++);
                // One tap → one line at every level so it's easy to compare
                // them side-by-side in DevTools.
                log.d('Burst from tap #$_tapCount — emitting all levels');
                _emitTrace();
                _emitDebug();
                _emitInfo();
                _emitWarning();
                _emitError();
              },
              icon: const Icon(Icons.bolt),
              label: const Text('Emit one of each level'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: () {
        setState(() => _tapCount++);
        onTap();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }

  @override
  void dispose() {
    log.d('LoggerDemoHome.dispose — cleaning up');
    // The Logger itself doesn't need disposing — it's just a singleton —
    // but if you used something like FileOutput you'd close it here.
    super.dispose();
  }
}
