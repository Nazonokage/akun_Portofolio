import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';

/// Animated corner-bracket stroke draw-in (decorative only).
class HudBracketPainter extends CustomPainter {
  final double progress;
  final Color color;

  HudBracketPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55 * progress)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    const arm = 14.0;
    const pad = 6.0;
    final w = size.width;
    final h = size.height;
    final len = arm * progress;

    void corner(double ax, double ay, double bx, double by, double cx, double cy) {
      if (len <= 0) return;
      canvas.drawLine(Offset(ax, ay), Offset(bx, by), paint);
      if (len > arm * 0.5) {
        canvas.drawLine(Offset(bx, by), Offset(cx, cy), paint);
      }
    }

    corner(pad, pad + len, pad, pad, pad + len, pad);
    corner(w - pad - len, pad, w - pad, pad, w - pad, pad + len);
    corner(pad, h - pad - len, pad, h - pad, pad + len, h - pad);
    corner(w - pad - len, h - pad, w - pad, h - pad, w - pad, h - pad - len);
  }

  @override
  bool shouldRepaint(HudBracketPainter old) =>
      old.progress != progress || old.color != color;
}

/// Platform-aware section entrance: desktop fade-up + bracket, mobile bracket-only,
/// tactic board on mobile web returns bare [child] with no wrappers.
class SectionReveal extends StatefulWidget {
  final Widget child;
  final bool isTacticBoardSection;
  final Color? bracketColor;

  const SectionReveal({
    super.key,
    required this.child,
    this.isTacticBoardSection = false,
    this.bracketColor,
  });

  @override
  State<SectionReveal> createState() => _SectionRevealState();
}

class _SectionRevealState extends State<SectionReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _curved;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    if (Perf.reduceMotion) _ctrl.value = 1.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onVisibility(VisibilityInfo info) {
    if (_triggered || Perf.reduceMotion) return;
    if (info.visibleFraction < 0.15) return;
    _triggered = true;
    _ctrl.forward();
  }

  Widget _bracketLayer(Color color) => IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _curved,
            builder: (_, __) => CustomPaint(
              painter: HudBracketPainter(
                progress: _curved.value,
                color: color,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (Perf.isMobileWeb && widget.isTacticBoardSection) {
      return widget.child;
    }

    final bracketColor = widget.bracketColor ?? AppColors.primary;

    if (Perf.isMobileWeb) {
      return VisibilityDetector(
        key: ValueKey('section_reveal_${widget.hashCode}'),
        onVisibilityChanged: _onVisibility,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: _bracketLayer(bracketColor)),
            widget.child,
          ],
        ),
      );
    }

    return VisibilityDetector(
      key: ValueKey('section_reveal_${widget.hashCode}'),
      onVisibilityChanged: _onVisibility,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: _bracketLayer(bracketColor)),
          AnimatedBuilder(
            animation: _curved,
            builder: (_, child) {
              final t = _curved.value;
              return Transform.translate(
                offset: Offset(0, (1 - t) * 24),
                child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
              );
            },
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
