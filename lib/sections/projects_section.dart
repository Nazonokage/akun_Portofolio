import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../data/profile_data.dart';
import '../widgets/hud_decorations.dart';
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
      label: '── FEATURED PROJECTS',
      triggerAt: 820,
      children: [
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 830,
          child: Text(
            'Tactical deployments — freelance, academic, and personal builds.',
            style: AppTypography.body(
              size: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _ProjectGrid(
          projects: ProfileData.featuredProjects,
          rawOffsetNotifier: rawOffsetNotifier,
          triggerBase: 850,
          isWide: isWide,
          columns: isWide ? 3 : 1,
        ),
        const SizedBox(height: 36),
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 1100,
          child: Text(
            'ACADEMIC & CAPSTONE',
            style: AppTypography.hudLabel(color: AppColors.secondary),
          ),
        ),
        const SizedBox(height: 16),
        _ProjectGrid(
          projects: ProfileData.projects,
          rawOffsetNotifier: rawOffsetNotifier,
          triggerBase: 1120,
          isWide: isWide,
          columns: isWide ? 3 : 1,
        ),
      ],
    );
  }
}

class _ProjectGrid extends StatelessWidget {
  final List<ProjectEntry> projects;
  final ValueNotifier<double> rawOffsetNotifier;
  final double triggerBase;
  final bool isWide;
  final int columns;

  const _ProjectGrid({
    required this.projects,
    required this.rawOffsetNotifier,
    required this.triggerBase,
    required this.isWide,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    if (columns == 1) {
      return Column(
        children: projects.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MorphReveal(
              offsetNotifier: rawOffsetNotifier,
              triggerAt: triggerBase + e.key * 40,
              delayMs: e.key * 80,
              child: _StatProjectCard(project: e.value),
            ),
          );
        }).toList(),
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < projects.length; i += columns) {
      final chunk = projects.skip(i).take(columns).toList();
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + columns < projects.length ? 16 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: chunk.asMap().entries.map((e) {
              final idx = i + e.key;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: e.key < chunk.length - 1 ? 16 : 0,
                  ),
                  child: MorphReveal(
                    offsetNotifier: rawOffsetNotifier,
                    triggerAt: triggerBase + idx * 40,
                    delayMs: idx * 80,
                    child: _StatProjectCard(project: e.value),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _StatProjectCard extends StatelessWidget {
  final ProjectEntry project;

  const _StatProjectCard({required this.project});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _categoryLabel(ProjectCategory cat) => switch (cat) {
        ProjectCategory.flutter => 'FLUTTER',
        ProjectCategory.web => 'WEB',
        ProjectCategory.backend => 'BACKEND',
        ProjectCategory.desktop => 'DESKTOP',
        ProjectCategory.tooling => 'TOOLING',
        ProjectCategory.security => 'SECURITY',
      };

  @override
  Widget build(BuildContext context) {
    return HudPanel(
      borderAlpha: 0.18,
      accentColor: project.accent,
      showCoordinates: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: project.accent.withValues(alpha: 0.4),
                  ),
                  color: project.accent.withValues(alpha: 0.08),
                ),
                child: Text(
                  _categoryLabel(project.category),
                  style: AppTypography.mono(
                    size: 7,
                    color: project.accent,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                project.year,
                style: AppTypography.mono(
                  size: 9,
                  color: project.accent.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            project.name.toUpperCase(),
            style: AppTypography.heading(
              size: 13,
              color: project.accent,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            project.subtitle,
            style: AppTypography.body(
              size: 11,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project.stack,
            style: AppTypography.mono(
              size: 9,
              color: AppColors.primary.withValues(alpha: 0.55),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...project.bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '▸ $b',
                style: AppTypography.body(
                  size: 11,
                  color: AppColors.textPrimary.withValues(alpha: 0.62),
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (project.githubUrl != null || project.liveUrl != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                if (project.githubUrl != null)
                  _LinkChip(
                    label: 'GITHUB',
                    onTap: () => _openUrl(project.githubUrl!),
                    color: project.accent,
                  ),
                if (project.liveUrl != null)
                  _LinkChip(
                    label: 'LIVE',
                    onTap: () => _openUrl(project.liveUrl!),
                    color: AppColors.success,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _LinkChip({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AppTypography.mono(size: 8, color: color),
        ),
      ),
    );
  }
}
