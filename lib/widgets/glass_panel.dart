import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';

/// Section header label used across portfolio sections.
class SectionLabel extends StatelessWidget {
  final String text;
  final int delayMs;

  const SectionLabel({super.key, required this.text, this.delayMs = 0});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTypography.hudLabel(
          color: AppColors.primary.withValues(alpha: 0.45),
        ),
      );
}

/// Glow chip for competencies, languages, frameworks.
class GlowChip extends StatefulWidget {
  final String label;
  final Color? color;

  const GlowChip({super.key, required this.label, this.color});

  @override
  State<GlowChip> createState() => _GlowChipState();
}

class _GlowChipState extends State<GlowChip> {
  bool _hovered = false;
  bool _tapActive = false;

  bool get _active => _hovered || _tapActive;

  void _tapFeedback() {
    if (!Perf.isMobileWeb) return;
    setState(() => _tapActive = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _tapActive = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? AppColors.primary;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _tapFeedback,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _active ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: c.withValues(alpha: _active ? 0.45 : 0.22),
              width: 1.0,
            ),
            color: AppColors.surface.withValues(alpha: _active ? 0.45 : 0.35),
            boxShadow: [
              BoxShadow(
                color: c.withValues(alpha: _active ? 0.14 : 0.06),
                blurRadius: _active ? 18 : 14,
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: AppTypography.mono(
              size: 10,
              color: c.withValues(alpha: _active ? 1.0 : 0.85),
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared faux-glass panel: alpha-gradient fill + border + optional glow shadow.
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
    this.padding = const EdgeInsets.all(AppLayout.padding),
    this.borderRadius = AppLayout.cornerRadius,
    this.borderAlpha = 0.55,
    this.accentColor,
    this.extraShadows,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;
    return Container(
      padding: padding,
      decoration: glassCardDecoration(
        borderAlpha: borderAlpha,
        radius: borderRadius,
        borderColor: accent,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: AppEffects.glowBlur,
            spreadRadius: AppEffects.glowSpread,
          ),
          ...?extraShadows,
        ],
      ),
      child: child,
    );
  }
}
