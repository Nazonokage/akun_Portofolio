import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/profile_data.dart';
import '../widgets/hud_decorations.dart';
import '../widgets/info_card.dart';
import '../widgets/morph_reveal.dart';
import 'section_shell.dart';

class AboutSection extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;

  const AboutSection({super.key, required this.rawOffsetNotifier});

  @override
  Widget build(BuildContext context) {
    return PortfolioSectionShell(
      rawOffsetNotifier: rawOffsetNotifier,
      label: '── PLAYER PROFILE',
      triggerAt: 200,
      children: [
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 220,
          child: HudPanel(
            borderAlpha: 0.16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ProfileData.fullName.toUpperCase(),
                  style: AppTypography.heading(size: 18, letterSpacing: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  ProfileData.role,
                  style: AppTypography.title(
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ProfileData.headline} · ${ProfileData.tagline}',
                  style: AppTypography.body(
                    size: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  ProfileData.profileSummary,
                  style: AppTypography.body(
                    size: 13,
                    color: AppColors.textPrimary.withValues(alpha: 0.68),
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final cards = ProfileData.aboutCards
                .asMap()
                .entries
                .map(
                  (e) => MorphReveal(
                    offsetNotifier: rawOffsetNotifier,
                    triggerAt: 280,
                    delayMs: 60 + e.key * 60,
                    child: InfoCard(
                      icon: e.value.icon,
                      title: e.value.title,
                      body: e.value.body,
                      accentColor: e.value.accent,
                    ),
                  ),
                )
                .toList();

            if (isWide) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[1]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[2]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[3]),
                    ],
                  ),
                ],
              );
            }
            return Column(
              children: cards
                  .expand((c) => [c, const SizedBox(height: 16)])
                  .toList()
                ..removeLast(),
            );
          },
        ),
      ],
    );
  }
}
