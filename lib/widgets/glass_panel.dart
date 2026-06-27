import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Shared faux-glass panel: alpha-gradient fill + border + optional glow shadow.
/// Matches the existing tactic-board card recipe (no BackdropFilter blur).
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double borderAlpha;
  final Color? accentColor;
  final List<BoxShadow>? extraShadows;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
    this.borderAlpha = 0.55,
    this.accentColor,
    this.extraShadows,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.neonGlow;
    return Container(
      padding: padding,
      decoration: glassCardDecoration(
        borderAlpha: borderAlpha,
        radius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: 1.2,
          ),
          ...?extraShadows,
        ],
      ),
      child: child,
    );
  }
}

/// Section header label used across portfolio sections.
class SectionLabel extends StatelessWidget {
  final String text;
  final int delayMs;

  const SectionLabel({super.key, required this.text, this.delayMs = 0});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.neonGlow.withValues(alpha: 0.45),
          letterSpacing: 3,
          fontFamily: 'monospace',
        ),
      );
}

/// Glow chip for competencies, languages, frameworks.
class GlowChip extends StatelessWidget {
  final String label;
  final Color? color;

  const GlowChip({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.neonGlow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.22), width: 1.0),
        color: AppColors.frame.withValues(alpha: 0.35),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.06),
            blurRadius: 14,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: c.withValues(alpha: 0.85),
          letterSpacing: 0.6,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
