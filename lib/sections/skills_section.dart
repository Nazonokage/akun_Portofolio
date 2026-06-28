import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/profile_data.dart';
import '../widgets/glass_panel.dart';
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
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _RadarPanel(),
                    ),
                    SizedBox(width: AppLayout.spacing),
                    Expanded(
                      child: _SkillBarsPanel(),
                    ),
                  ],
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
          child: _ChipGroup(
            title: 'CORE COMPETENCIES',
            items: ProfileData.coreCompetencies,
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
                        ),
                      ),
                      SizedBox(width: AppLayout.spacing),
                      Expanded(
                        child: _ChipGroup(
                          title: 'FRAMEWORKS / LIBRARIES',
                          items: ProfileData.frameworks,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: AppLayout.spacing),
                      Expanded(
                        child: _ChipGroup(
                          title: 'DATABASES & TOOLS',
                          items: ProfileData.tools,
                          color: AppColors.warning,
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
                    ),
                    SizedBox(height: AppLayout.spacing),
                    _ChipGroup(
                      title: 'FRAMEWORKS / LIBRARIES',
                      items: ProfileData.frameworks,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: AppLayout.spacing),
                    _ChipGroup(
                      title: 'DATABASES & TOOLS',
                      items: ProfileData.tools,
                      color: AppColors.warning,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _RadarPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > AppBalance.wideBreakpoint;

    return HudPanel(
      borderAlpha: 0.16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ATTRIBUTE RADAR',
            style: AppTypography.hudLabel(color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Systems-oriented strengths — troubleshooting, networking, integration, and delivery.',
            style: AppTypography.body(
              size: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SkillsRadarChart(
              attributes: ProfileData.hudAttributes,
              size: isWide ? 200 : 180,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillBarsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderAlpha: 0.14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELF-ASSESSED READOUTS',
            style: AppTypography.hudLabel(color: AppColors.secondary),
          ),
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
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color? color;

  const _ChipGroup({
    required this.title,
    required this.items,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderAlpha: 0.12,
      padding: const EdgeInsets.all(AppLayout.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.hudLabel(
              color: (color ?? AppColors.primary).withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((i) => GlowChip(label: i, color: color)).toList(),
          ),
        ],
      ),
    );
  }
}
