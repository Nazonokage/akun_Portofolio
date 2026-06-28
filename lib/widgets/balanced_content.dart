import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Centers page content and caps width so sections stay visually balanced
/// on ultrawide viewports (equal negative space left/right).
class BalancedContent extends StatelessWidget {
  final Widget child;

  const BalancedContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppBalance.maxContentWidth),
        child: child,
      ),
    );
  }
}
