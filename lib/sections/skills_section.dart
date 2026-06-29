import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/profile_data.dart';
import '../widgets/glass_panel.dart';
import '../widgets/hover_card.dart';
import '../widgets/hud_decorations.dart';
import '../widgets/morph_reveal.dart';
import '../widgets/radar_chart.dart';
import '../widgets/readouts.dart';
import 'section_shell.dart';

class SkillsSection extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;

  const SkillsSection({super.key, required this.rawOffsetNotifier});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > AppBalance.wideBreakpoint;

    return PortfolioSectionShell(
      rawOffsetNotifier: rawOffsetNotifier,
      label: '── SKILL PROFILE',
      triggerAt: 480,
      children: [
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 500,
          child: isWide
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _RadarPanel()),
                      SizedBox(width: AppLayout.spacing),
                      Expanded(child: _SkillBarsPanel()),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _RadarPanel(),
                    SizedBox(height: AppLayout.spacing),
                    _SkillBarsPanel(),
                  ],
                ),
        ),
        SizedBox(height: AppLayout.spacing),
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 540,
          delayMs: 80,
          child: const _ChipGroup(
            title: 'CORE COMPETENCIES',
            items: ProfileData.coreCompetencies,
            stripeIndex: 0,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppLayout.spacing),
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 560,
          delayMs: 120,
          child: isWide
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _ChipGroup(
                          title: 'LANGUAGES',
                          items: ProfileData.languages,
                          color: AppColors.secondary,
                          stripeIndex: 1,
                        ),
                      ),
                      SizedBox(width: AppLayout.spacing),
                      Expanded(
                        child: _ChipGroup(
                          title: 'FRAMEWORKS / LIBRARIES',
                          items: ProfileData.frameworks,
                          color: AppColors.primary,
                          stripeIndex: 2,
                          stripeFlip: true,
                        ),
                      ),
                      SizedBox(width: AppLayout.spacing),
                      Expanded(
                        child: _ChipGroup(
                          title: 'DATABASES & TOOLS',
                          items: ProfileData.tools,
                          color: AppColors.warning,
                          stripeIndex: 3,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _ChipGroup(
                      title: 'LANGUAGES',
                      items: ProfileData.languages,
                      color: AppColors.secondary,
                      stripeIndex: 1,
                    ),
                    SizedBox(height: AppLayout.spacing),
                    _ChipGroup(
                      title: 'FRAMEWORKS / LIBRARIES',
                      items: ProfileData.frameworks,
                      color: AppColors.primary,
                      stripeIndex: 2,
                      stripeFlip: true,
                    ),
                    SizedBox(height: AppLayout.spacing),
                    _ChipGroup(
                      title: 'DATABASES & TOOLS',
                      items: ProfileData.tools,
                      color: AppColors.warning,
                      stripeIndex: 3,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ── Radar panel ───────────────────────────────────────────────────────────────

class _RadarPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > AppBalance.wideBreakpoint;

    return HoverCard(
      accent: AppColors.secondary,
      child: HudPanel(
        borderAlpha: 0.16,
        padding: EdgeInsets.zero,
        // Self-contained: don't rely on a caller-provided IntrinsicHeight.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AccentStripe(
                  accent: AppColors.secondary, index: 0, label: 'RADAR'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppLayout.padding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ATTRIBUTE RADAR',
                          style: AppTypography.hudLabel(
                              color: AppColors.secondary)),
                      const SizedBox(height: 8),
                      Text(
                        'Systems-oriented strengths — troubleshooting, networking, integration, and delivery.',
                        style: AppTypography.body(
                            size: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SkillsRadarChart(
                          attributes: ProfileData.hudAttributes,
                          size: isWide ? 180 : 160,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skill bars panel ──────────────────────────────────────────────────────────

class _SkillBarsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HoverCard(
      accent: AppColors.primary,
      child: GlassPanel(
        borderAlpha: 0.14,
        padding: EdgeInsets.zero,
        // Self-contained: don't rely on a caller-provided IntrinsicHeight.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppLayout.padding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SELF-ASSESSED READOUTS',
                          style: AppTypography.hudLabel(
                              color: AppColors.secondary)),
                      const SizedBox(height: 18),
                      ...ProfileData.ratedSkills.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: SkillBar(
                            label: s.name.toUpperCase(),
                            value: s.normalized,
                            score: s.score,
                            maxScore: s.maxScore,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _AccentStripe(
                  accent: AppColors.primary,
                  index: 1,
                  label: 'SKILLS',
                  flip: true),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chip group ────────────────────────────────────────────────────────────────

class _ChipGroup extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color? color;
  final int stripeIndex;
  final bool stripeFlip;

  const _ChipGroup({
    required this.title,
    required this.items,
    this.color,
    this.stripeIndex = 0,
    this.stripeFlip = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    final stripeLabel = title.length > 6 ? title.substring(0, 6) : title;

    return HoverCard(
      accent: accent,
      child: GlassPanel(
        borderAlpha: 0.12,
        padding: EdgeInsets.zero,
        accentColor: accent,
        // Self-contained IntrinsicHeight: _ChipGroup is sometimes used standalone
        // (no IntrinsicHeight ancestor), so it must not assume one is provided —
        // otherwise this Row gets an unbounded height inside the page's
        // SingleChildScrollView and crashes ("BoxConstraints forces an infinite height").
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!stripeFlip)
                _AccentStripe(
                    accent: accent, index: stripeIndex, label: stripeLabel),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppLayout.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: AppTypography.hudLabel(
                              color: accent.withValues(alpha: 0.8))),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: items
                            .map((i) => GlowChip(label: i, color: color))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              if (stripeFlip)
                _AccentStripe(
                    accent: accent,
                    index: stripeIndex,
                    label: stripeLabel,
                    flip: true),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Accent stripe ─────────────────────────────────────────────────────────────

class _AccentStripe extends StatelessWidget {
  final Color accent;
  final int index;
  final String label;
  final bool flip;

  const _AccentStripe({
    required this.accent,
    required this.index,
    required this.label,
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    final indexStr = (index + 1).toString().padLeft(2, '0');
    return Container(
      width: 32,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        border: Border(
          left: flip
              ? BorderSide.none
              : BorderSide(color: accent.withValues(alpha: 0.28), width: 2),
          right: flip
              ? BorderSide(color: accent.withValues(alpha: 0.28), width: 2)
              : BorderSide.none,
        ),
      ),
      // CustomPaint without a child — size is driven by parent Container width + stretch height
      child: CustomPaint(
        painter: _StripePainter(accent: accent),
        child: Center(
          child: RotatedBox(
            quarterTurns: flip ? 1 : 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(indexStr,
                    style: AppTypography.mono(
                        size: 7, color: accent, letterSpacing: 1.5)),
                const SizedBox(width: 4),
                Text('·',
                    style: AppTypography.mono(
                        size: 7, color: accent.withValues(alpha: 0.4))),
                const SizedBox(width: 4),
                Text(label,
                    style: AppTypography.mono(
                        size: 6,
                        color: accent.withValues(alpha: 0.55),
                        letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stripe background painter ─────────────────────────────────────────────────

class _StripePainter extends CustomPainter {
  final Color accent;
  const _StripePainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const spacing = 8.0;
    for (double d = -size.height; d < size.width + size.height; d += spacing) {
      canvas.drawLine(
          Offset(d, 0), Offset(d + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.accent != accent;
}
