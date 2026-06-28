import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/profile_data.dart';

/// Football-style attribute radar chart for skills HUD.
class SkillsRadarChart extends StatelessWidget {
  final List<SkillRating> attributes;
  final double size;

  const SkillsRadarChart({
    super.key,
    required this.attributes,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size + attributes.length * 14,
      child: Column(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RadarPainter(attributes: attributes),
              child: Center(
                child: Text(
                  'ATTR',
                  style: AppTypography.hudLabel(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: attributes
                .map(
                  (a) => Text(
                    '${a.name.toUpperCase()} ${a.score}',
                    style: AppTypography.mono(
                      size: 8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<SkillRating> attributes;

  _RadarPainter({required this.attributes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 24;
    final n = attributes.length;
    if (n < 3) return;

    final gridPaint = Paint()
      ..color = AppColors.grid.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var ring = 1; ring <= 4; ring++) {
      final r = radius * ring / 4;
      final path = Path();
      for (var i = 0; i < n; i++) {
        final angle = _angle(i, n);
        final pt = _polar(center, r, angle);
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < n; i++) {
      final angle = _angle(i, n);
      final pt = _polar(center, radius, angle);
      canvas.drawLine(center, pt, gridPaint);
    }

    final fillPath = Path();
    for (var i = 0; i < n; i++) {
      final angle = _angle(i, n);
      final val = attributes[i].normalized;
      final pt = _polar(center, radius * val, angle);
      i == 0 ? fillPath.moveTo(pt.dx, pt.dy) : fillPath.lineTo(pt.dx, pt.dy);
    }
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    for (var i = 0; i < n; i++) {
      final angle = _angle(i, n);
      final val = attributes[i].normalized;
      final pt = _polar(center, radius * val, angle);
      canvas.drawCircle(
        pt,
        3.5,
        Paint()..color = AppColors.primary,
      );
      canvas.drawCircle(
        pt,
        6,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      final labelPt = _polar(center, radius + 16, angle);
      final tp = TextPainter(
        text: TextSpan(
          text: attributes[i].name.split(' ').first.toUpperCase(),
          style: AppTypography.mono(size: 7, color: AppColors.textSecondary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(labelPt.dx - tp.width / 2, labelPt.dy - tp.height / 2),
      );
    }
  }

  double _angle(int i, int n) => -math.pi / 2 + (2 * math.pi * i / n);

  Offset _polar(Offset center, double r, double angle) =>
      Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.attributes != attributes;
}
