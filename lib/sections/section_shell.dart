import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../widgets/morph_reveal.dart';

class PortfolioSectionShell extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;
  final String label;
  final double triggerAt;
  final List<Widget> children;

  const PortfolioSectionShell({
    super.key,
    required this.rawOffsetNotifier,
    required this.label,
    required this.triggerAt,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = AppBalance.sectionPadding(width);
    final labelGap = width < AppBalance.compactBreakpoint ? 24.0 : 32.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MorphReveal(
              offsetNotifier: rawOffsetNotifier,
              triggerAt: triggerAt,
              child: SectionLabel(text: label),
            ),
            SizedBox(height: labelGap),
            ...children,
          ],
        ),
      ),
    );
  }
}
