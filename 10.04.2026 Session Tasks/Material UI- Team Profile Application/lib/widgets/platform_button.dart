// lib/widgets/platform_button.dart
//
// Platform-aware button. On iOS we use a CupertinoButton so it looks native;
// everywhere else we use a filled Material IconButton. This satisfies the
// homework's optional bullet:
//
//   "You can include a Cupertino widget for iOS build if you want.
//    In code, you can check whether the app is currently on iOS and select
//    the widget run-time."
//
// I use `Theme.of(context).platform` instead of `dart:io`'s `Platform.isIOS`
// because the dart:io approach doesn't compile for Flutter Web. Theme's
// platform value works on every target.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final bool primary;

  const PlatformIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final cs = Theme.of(context).colorScheme;

    final isIOS = platform == TargetPlatform.iOS;

    if (isIOS) {
      // Cupertino flavor for iOS users.
      return CupertinoButton(
        padding: const EdgeInsets.all(12),
        color: primary ? cs.primary : cs.secondaryContainer,
        borderRadius: BorderRadius.circular(28),
        onPressed: onPressed,
        child: Icon(
          icon,
          color: primary ? cs.onPrimary : cs.onSecondaryContainer,
          semanticLabel: semanticLabel,
        ),
      );
    }

    // Material flavor (Android, Linux, Windows, macOS, Web).
    return Material(
      color: primary ? cs.primary : cs.secondaryContainer,
      shape: const CircleBorder(),
      elevation: primary ? 2 : 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: primary ? cs.onPrimary : cs.onSecondaryContainer,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}
