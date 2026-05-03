// lib/utils/app_logger.dart
//
// One Logger instance for the whole app. Importing this file gives every
// screen and widget access to `log.d()`, `log.i()`, `log.w()`, `log.e()`,
// without needing to thread it through constructors or InheritedWidgets.
//
// This is the same pattern as in the page-45 logging exercise — I just
// pulled it out into its own file so main.dart stays uncluttered.

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:logger/logger.dart';

/// Single, app-wide Logger. Initialized exactly once from main().
late final Logger log;

/// Call this from main() before runApp().
void initAppLogger() {
  log = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    // Verbose during development, warnings-and-up in release.
    level: kDebugMode ? Level.debug : Level.warning,
  );
}
