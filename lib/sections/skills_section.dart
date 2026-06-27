import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/profile_data.dart';
import '../widgets/glass_panel.dart';
import '../widgets/morph_reveal.dart';
import '../widgets/readouts.dart';
import 'section_shell.dart';

class SkillsSection extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;

  const SkillsSection({super.key, required this.rawOffsetNotifier});

  @override
  Widget build(BuildContext context) {
    return PortfolioSectionShell(
      rawOffsetNotifier: rawOffsetNotifier,
      label: '── SKILLS',
      triggerAt: 480,
      children: [
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 500,
          child: GlassPanel(
            borderAlpha: 0.14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELF-ASSESSED READOUTS',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.hologram,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
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
          ),
        ),
        const SizedBox(height: 20),
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 540,
          delayMs: 80,
          child: _ChipGroup(
            title: 'CORE COMPETENCIES',
            items: ProfileData.coreCompetencies,
          ),
        ),
        const SizedBox(height: 16),
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 560,
          delayMs: 120,
          child: _ChipGroup(
            title: 'LANGUAGES',
            items: ProfileData.languages,
            color: AppColors.hologram,
          ),
        ),
        const SizedBox(height: 16),
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 580,
          delayMs: 160,
          child: _ChipGroup(
            title: 'FRAMEWORKS / LIBRARIES',
            items: ProfileData.frameworks,
            color: AppColors.secondaryGlow,
          ),
        ),
        const SizedBox(height: 16),
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 600,
          delayMs: 200,
          child: _ChipGroup(
            title: 'DATABASES & TOOLS',
            items: ProfileData.tools,
            color: AppColors.accent3,
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: (color ?? AppColors.neonGlow).withValues(alpha: 0.8),
              letterSpacing: 2,
              fontFamily: 'monospace',
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
