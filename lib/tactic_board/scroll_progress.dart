import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Accurate scroll-depth HUD bar — reads live maxScrollExtent so the fill
/// reaches 100% only at the true bottom of the page.
class ScrollProgressBar extends StatefulWidget {
  final ScrollController controller;

  const ScrollProgressBar({super.key, required this.controller});

  @override
  State<ScrollProgressBar> createState() => _ScrollProgressBarState();
}

class _ScrollProgressBarState extends State<ScrollProgressBar> {
  double _depth = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncDepth);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncDepth());
  }

  @override
  void didUpdateWidget(covariant ScrollProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncDepth);
      widget.controller.addListener(_syncDepth);
      _syncDepth();
    }
  }

  void _syncDepth() {
    if (!widget.controller.hasClients) return;
    final pos = widget.controller.position;
    final next = AppBalance.scrollDepth(pos.pixels, pos.maxScrollExtent);
    if ((_depth - next).abs() > 0.001 && mounted) {
      setState(() => _depth = next);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncDepth);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_depth * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppLayout.cornerRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: AppLayout.borderWidth * 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: AppEffects.glowBlur,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'DEPTH',
            style: AppTypography.hudLabel(
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _depth,
                backgroundColor: AppColors.grid.withValues(alpha: 0.35),
                color: AppColors.primary,
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(
              '$pct%',
              textAlign: TextAlign.right,
              style: AppTypography.mono(
                size: 10,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
