import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/profile_data.dart';
import '../widgets/glass_panel.dart';
import '../widgets/morph_reveal.dart';
import 'section_shell.dart';

class ExperienceSection extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;

  const ExperienceSection({super.key, required this.rawOffsetNotifier});

  @override
  Widget build(BuildContext context) {
    return PortfolioSectionShell(
      rawOffsetNotifier: rawOffsetNotifier,
      label: '── EXPERIENCE',
      triggerAt: 640,
      children: [
        ...ProfileData.experience.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MorphReveal(
                  offsetNotifier: rawOffsetNotifier,
                  triggerAt: 660 + e.key * 40,
                  delayMs: e.key * 60,
                  child: _ExperienceCard(entry: e.value),
                ),
              ),
            ),
      ],
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final ExperienceEntry entry;

  const _ExperienceCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderAlpha: 0.14,
      accentColor: AppColors.hologram,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.company,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neonGlow.withValues(alpha: 0.85),
                      ),
                    ),
                    if (entry.location.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.location,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryGlow.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.neonGlow.withValues(alpha: 0.25),
                  ),
                  color: AppColors.frame.withValues(alpha: 0.4),
                ),
                child: Text(
                  entry.period,
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.neonGlow.withValues(alpha: 0.9),
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...entry.bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '▸ ',
                    style: TextStyle(
                      color: AppColors.hologram.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.65),
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
