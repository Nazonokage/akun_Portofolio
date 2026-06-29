import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';
import '../data/profile_data.dart';
import '../tactic_board/floating_board.dart';
import '../tactic_board/stats_panel.dart';
import '../widgets/hud_decorations.dart';

class HeroSection extends StatefulWidget {
  final ValueNotifier<double> scrollProgressNotifier;
  final ValueNotifier<bool> editModeNotifier;
  final VoidCallback? onViewProjects;

  const HeroSection({
    super.key,
    required this.scrollProgressNotifier,
    required this.editModeNotifier,
    this.onViewProjects,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  String _currentFormation = "4-2-3-1";

  void _onFormationChanged(String newFormation) {
    if (_currentFormation == newFormation) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _currentFormation = newFormation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final screenWidth = mq.width;
    final isLandscape = screenWidth > mq.height;
    final isWide = screenWidth > 700 || (isLandscape && screenWidth > 500);

    // Static content — lives in ValueListenableBuilder's `child` so it never
    // rebuilds on scroll ticks.
    final staticPanel = HudPanel(
      borderAlpha: 0.22,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 20 : 14,
        vertical: isWide ? 16 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HudHeader(isWide: isWide),
          const SizedBox(height: 14),
          Text(
            ProfileData.fullName.toUpperCase(),
            style: AppTypography.heading(
                size: isWide ? 16 : 13, letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            ProfileData.role,
            style: AppTypography.title(
                size: isWide ? 15 : 13, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            ProfileData.heroCaption,
            style: AppTypography.caption(
              size: 10,
              color: AppColors.primary.withValues(alpha: 0.75),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ProfileData.heroSubcaption,
            style: AppTypography.body(
              size: isWide ? 12 : 11,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _TacticalCta(
                  label: 'VIEW TACTICAL PROJECTS',
                  onPressed: widget.onViewProjects),
              if (isWide)
                SkillsRadarMini(attributes: ProfileData.hudAttributes),
            ],
          ),
        ],
      ),
    );

    return ValueListenableBuilder<double>(
      valueListenable: widget.scrollProgressNotifier,
      // Pass static panel as `child` — Flutter reuses it across rebuilds.
      child: staticPanel,
      builder: (_, scrollProgress, staticChild) {
        final boardT =
            snapCurve.transform((scrollProgress / 0.6).clamp(0.0, 1.0));
        final statsT = snapCurve
            .transform(((scrollProgress - 0.15) / 0.75).clamp(0.0, 1.0));

        final board = BoardTransform(
          boardT: boardT,
          isLandscape: isLandscape,
          isMobile: mq.shortestSide < 600,
          child: Center(
            child: FloatingTacticBoard(
              onFormationChanged: _onFormationChanged,
              editModeNotifier: widget.editModeNotifier,
            ),
          ),
        );

        final stats = StatsTransform(
          statsT: statsT,
          child: StatsPanel(formation: _currentFormation),
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppBalance.horizontalInset(screenWidth),
            vertical: isWide ? 36 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              staticChild!,
              const SizedBox(height: 24),
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: board),
                        const SizedBox(width: 36),
                        Expanded(flex: 4, child: stats),
                      ],
                    )
                  : Column(
                      children: [board, const SizedBox(height: 36), stats]),
            ],
          ),
        );
      },
    );
  }
}

// ── HUD header ────────────────────────────────────────────────────────────────

class _HudHeader extends StatelessWidget {
  final bool isWide;
  const _HudHeader({required this.isWide});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _RatingBadge(rating: ProfileData.overallRating),
          const SizedBox(width: 14),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _HudChip(label: 'POS', value: ProfileData.position),
                _HudChip(label: 'NAT', value: ProfileData.nationality),
                if (isWide) ...[
                  _HudChip(label: 'FOOT', value: ProfileData.preferredFoot),
                  _HudChip(label: 'VALUE', value: ProfileData.marketValue),
                ],
              ],
            ),
          ),
          Text(
            'PLAYER PROFILE',
            style: AppTypography.hudLabel(
                color: AppColors.secondary.withValues(alpha: 0.5)),
          ),
        ],
      );
}

// ── Rating badge ──────────────────────────────────────────────────────────────

class _RatingBadge extends StatelessWidget {
  final int rating;
  const _RatingBadge({required this.rating});

  // Badge decoration never changes — cache it.
  static final _decoration = BoxDecoration(
    border:
        Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 2),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.surface.withValues(alpha: 0.8),
        AppColors.surfaceVariant.withValues(alpha: 0.4),
      ],
    ),
    boxShadow: [
      BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12)
    ],
  );

  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        height: 52,
        decoration: _decoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$rating',
                style:
                    AppTypography.heading(size: 20, color: AppColors.primary)),
            Text('OVR',
                style: AppTypography.mono(
                    size: 7, color: AppColors.textSecondary)),
          ],
        ),
      );
}

// ── Hud chip ──────────────────────────────────────────────────────────────────

class _HudChip extends StatelessWidget {
  final String label;
  final String value;
  const _HudChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => readoutChip(label: label, value: value);
}

// ── CTA button ────────────────────────────────────────────────────────────────

class _TacticalCta extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _TacticalCta({required this.label, this.onPressed});

  // Decoration is constant — allocate once.
  static final _decoration = BoxDecoration(
    border: Border.all(
        color: AppColors.primary.withValues(alpha: 0.55), width: 1.5),
    borderRadius: BorderRadius.circular(8),
    gradient: LinearGradient(colors: [
      AppColors.primary.withValues(alpha: 0.12),
      AppColors.secondary.withValues(alpha: 0.06),
    ]),
    boxShadow: [
      BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 14)
    ],
  );

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: _decoration,
            child: Text(
              label,
              style: AppTypography.mono(
                  size: 10, color: AppColors.primary, letterSpacing: 1.2),
            ),
          ),
        ),
      );
}

// ── Mini radar ────────────────────────────────────────────────────────────────

class SkillsRadarMini extends StatelessWidget {
  final List<SkillRating> attributes;
  const SkillsRadarMini({super.key, required this.attributes});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 80,
        height: 80,
        child: CustomPaint(painter: _MiniRadarPainter(attributes: attributes)),
      );
}

class _MiniRadarPainter extends CustomPainter {
  final List<SkillRating> attributes;

  // Reuse paint objects — avoids allocations on every repaint.
  static final _fillPaint = Paint()
    ..color = AppColors.primary.withValues(alpha: 0.2)
    ..style = PaintingStyle.fill;
  static final _strokePaint = Paint()
    ..color = AppColors.primary.withValues(alpha: 0.7)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  const _MiniRadarPainter({required this.attributes});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final radius = cx - 4;
    final n = attributes.length;
    final path = Path();
    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final r = radius * attributes[i].normalized;
      final pt = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas
      ..drawPath(path, _fillPaint)
      ..drawPath(path, _strokePaint);
  }

  @override
  bool shouldRepaint(_MiniRadarPainter old) => old.attributes != attributes;
}

// ── Board transform ───────────────────────────────────────────────────────────

class BoardTransform extends StatelessWidget {
  final double boardT;
  final bool isLandscape;
  // Accept pre-computed isMobile so we don't call MediaQuery inside a
  // scroll-driven rebuild scope.
  final bool isMobile;
  final Widget child;

  const BoardTransform({
    super.key,
    required this.boardT,
    required this.isLandscape,
    required this.isMobile,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (Perf.isMobileWeb || isLandscape || isMobile) return child;

    final opacity = (1.0 - boardT * 0.7).clamp(0.0, 1.0);
    if (Perf.lightEffects) {
      return Transform.translate(
        offset: Offset(0, boardT * -28.0),
        child: Opacity(opacity: opacity, child: child),
      );
    }
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0009)
        ..translateByDouble(0.0, boardT * -28.0, 0.0, 1.0)
        ..rotateX(boardT * 36.0 * math.pi / 180)
        ..scaleByDouble(1.0 - boardT * 0.13, 1.0 - boardT * 0.13, 1.0, 1.0),
      child: Opacity(opacity: opacity, child: child),
    );
  }
}

// ── Stats transform ───────────────────────────────────────────────────────────

class StatsTransform extends StatelessWidget {
  final double statsT;
  final Widget child;

  const StatsTransform({super.key, required this.statsT, required this.child});

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - statsT * 0.3).clamp(0.0, 1.0);
    return Transform(
      alignment: Alignment.topCenter,
      transform: Matrix4.identity()
        ..translateByDouble(0.0, statsT * -12.0, 0.0, 1.0)
        ..scaleByDouble(1.0 - statsT * 0.05, 1.0 - statsT * 0.05, 1.0, 1.0),
      child: Opacity(opacity: opacity, child: child),
    );
  }
}
