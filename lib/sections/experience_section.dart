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
      label: '── MATCH TIMELINE',
      triggerAt: 640,
      children: [
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 655,
          child: Text(
            'Career events plotted like match incidents — deployments, support, hardware, freelance.',
            style: AppTypography.body(
              size: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...ProfileData.experience.asMap().entries.map(
              (e) => MorphReveal(
                offsetNotifier: rawOffsetNotifier,
                triggerAt: 660 + e.key * 40,
                delayMs: e.key * 60,
                child: _TimelineNode(
                  entry: e.value,
                  isLast: e.key == ProfileData.experience.length - 1,
                ),
              ),
            ),
      ],
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final ExperienceEntry entry;
  final bool isLast;

  const _TimelineNode({required this.entry, required this.isLast});

  _EventStyle _style(MatchEventType type) => switch (type) {
        MatchEventType.deployment => _EventStyle(
            icon: Icons.rocket_launch_outlined,
            color: AppColors.primary,
            label: 'DEPLOY',
          ),
        MatchEventType.support => _EventStyle(
            icon: Icons.headset_mic_outlined,
            color: AppColors.secondary,
            label: 'SUPPORT',
          ),
        MatchEventType.hardware => _EventStyle(
            icon: Icons.memory_outlined,
            color: AppColors.warning,
            label: 'HARDWARE',
          ),
        MatchEventType.freelance => _EventStyle(
            icon: Icons.code_outlined,
            color: AppColors.success,
            label: 'FREELANCE',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final style = _style(entry.eventType);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppLayout.spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineMarker(style: style, isLast: isLast),
          const SizedBox(width: 12),
          Expanded(
            child: GlassPanel(
              borderAlpha: 0.14,
              accentColor: style.color,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.1),
                          border: Border.all(
                            color: style.color.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          style.label,
                          style: AppTypography.mono(
                            size: 7,
                            color: style.color,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          entry.period,
                          textAlign: TextAlign.right,
                          style: AppTypography.mono(
                            size: 9,
                            color: AppColors.primary.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    entry.title.toUpperCase(),
                    style: AppTypography.heading(size: 11, letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.company,
                    style: AppTypography.title(
                      size: 12,
                      color: AppColors.primary.withValues(alpha: 0.85),
                    ),
                  ),
                  if (entry.location.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.location,
                      style: AppTypography.caption(size: 11),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ...entry.bullets.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '▸ ',
                            style: TextStyle(
                              color: style.color.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              b,
                              style: AppTypography.body(
                                size: 12,
                                color: AppColors.textPrimary.withValues(alpha: 0.65),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineMarker extends StatelessWidget {
  final _EventStyle style;
  final bool isLast;

  const _TimelineMarker({required this.style, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: style.color.withValues(alpha: 0.6),
                width: 2,
              ),
              color: style.color.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: style.color.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(style.icon, size: 16, color: style.color),
          ),
          if (!isLast)
            Container(
              width: 2,
              height: 24,
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    style.color.withValues(alpha: 0.5),
                    AppColors.grid.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventStyle {
  final IconData icon;
  final Color color;
  final String label;

  const _EventStyle({
    required this.icon,
    required this.color,
    required this.label,
  });
}
