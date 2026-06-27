import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/profile_data.dart';
import '../widgets/glass_panel.dart';
import '../widgets/morph_reveal.dart';
import 'section_shell.dart';

class ProjectsSection extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;

  const ProjectsSection({super.key, required this.rawOffsetNotifier});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;

    return PortfolioSectionShell(
      rawOffsetNotifier: rawOffsetNotifier,
      label: '── PROJECTS',
      triggerAt: 820,
      children: [
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ProfileData.projects
                .asMap()
                .entries
                .map(
                  (e) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: e.key < ProfileData.projects.length - 1 ? 16 : 0,
                      ),
                      child: MorphReveal(
                        offsetNotifier: rawOffsetNotifier,
                        triggerAt: 840 + e.key * 40,
                        delayMs: e.key * 80,
                        child: _ProjectCard(project: e.value),
                      ),
                    ),
                  ),
                )
                .toList(),
          )
        else
          ...ProfileData.projects.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MorphReveal(
                    offsetNotifier: rawOffsetNotifier,
                    triggerAt: 840 + e.key * 40,
                    delayMs: e.key * 80,
                    child: _ProjectCard(project: e.value),
                  ),
                ),
              ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectEntry project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderAlpha: 0.14,
      accentColor: project.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: project.accent,
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Text(
                project.year,
                style: TextStyle(
                  fontSize: 10,
                  color: project.accent.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            project.subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryGlow.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project.stack,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.neonGlow.withValues(alpha: 0.55),
              letterSpacing: 0.5,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 14),
          ...project.bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '· $b',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.62),
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
