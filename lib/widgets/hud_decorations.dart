import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Corner-cut HUD panel with micro-grid overlay and floating coordinates.
class HudPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderAlpha;
  final Color? accentColor;
  final bool showCoordinates;
  final bool showCornerDots;

  const HudPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppLayout.padding),
    this.borderAlpha = 0.35,
    this.accentColor,
    this.showCoordinates = true,
    this.showCornerDots = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: padding,
          decoration: glassCardDecoration(
            borderAlpha: borderAlpha,
            borderColor: accent,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: AppEffects.glowBlur,
                spreadRadius: AppEffects.glowSpread,
              ),
            ],
          ),
          child: Stack(
            children: [
              if (showCornerDots)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MicroGridPainter(
                      color: AppColors.grid.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              child,
            ],
          ),
        ),
        if (showCornerDots) ..._cornerDots(accent),
        if (showCoordinates)
          Positioned(
            top: 6,
            right: 10,
            child: Text(
              _coords(),
              style: AppTypography.mono(
                size: 7,
                color: accent.withValues(alpha: 0.35),
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }

  String _coords() {
    final r = math.Random(42);
    return 'X:${(r.nextDouble() * 90 + 10).toStringAsFixed(1)} '
        'Y:${(r.nextDouble() * 90 + 10).toStringAsFixed(1)}';
  }

  List<Widget> _cornerDots(Color accent) => [
        _dot(0, 0, accent),
        _dot(null, 0, accent, right: 0),
        _dot(0, null, accent, bottom: 0),
        _dot(null, null, accent, right: 0, bottom: 0),
      ];

  Widget _dot(
    double? left,
    double? top,
    Color accent, {
    double? right,
    double? bottom,
  }) =>
      Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.6),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      );
}

class _MicroGridPainter extends CustomPainter {
  final Color color;
  _MicroGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    const step = 12.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Angled clip for HUD panels — cuts top-left and bottom-right corners.
class AngledClipper extends CustomClipper<Path> {
  final double cutSize;

  const AngledClipper({this.cutSize = 14});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(cutSize, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cutSize)
      ..lineTo(size.width - cutSize, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, cutSize)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
