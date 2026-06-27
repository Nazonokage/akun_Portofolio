import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';
import '../data/profile_data.dart';
import '../tactic_board/floating_board.dart';
import '../tactic_board/stats_panel.dart';
import '../widgets/glass_panel.dart';

// ─── Hero Section ─────────────────────────────────────────────────────────
class HeroSection extends StatefulWidget {
  final ValueNotifier<double> scrollProgressNotifier;
  final ValueNotifier<bool> editModeNotifier;
  const HeroSection({
    required this.scrollProgressNotifier,
    required this.editModeNotifier,
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
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final isLandscape = screenWidth > screenHeight;
    final isWide = screenWidth > 700 || (isLandscape && screenWidth > 500);

    return ValueListenableBuilder<double>(
      valueListenable: widget.scrollProgressNotifier,
      builder: (_, scrollProgress, child) {
        final boardT = snapCurve.transform(
          (scrollProgress / 0.6).clamp(0.0, 1.0),
        );
        final statsT = snapCurve.transform(
          ((scrollProgress - 0.15) / 0.75).clamp(0.0, 1.0),
        );

        Widget board = BoardTransform(
          boardT: boardT,
          isLandscape: isLandscape,
          child: Center(
            child: FloatingTacticBoard(
              onFormationChanged: _onFormationChanged,
              editModeNotifier: widget.editModeNotifier,
            ),
          ),
        );

        Widget stats = StatsTransform(
          statsT: statsT,
          child: StatsPanel(formation: _currentFormation),
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 36 : 20,
            vertical: isWide ? 36 : 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassPanel(
                borderAlpha: 0.12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ProfileData.fullName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.4,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ProfileData.heroCaption,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.neonGlow.withValues(alpha: 0.75),
                        letterSpacing: 0.6,
                        height: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ProfileData.heroSubcaption,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryGlow.withValues(alpha: 0.68),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
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
                      children: [board, const SizedBox(height: 36), stats],
                    ),
            ],
          ),
        );
      },
    );
  }
}

class BoardTransform extends StatelessWidget {
  final double boardT;
  final bool isLandscape;
  final Widget child;

  const BoardTransform({
    required this.boardT,
    required this.isLandscape,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLandscape) {
      return Opacity(opacity: 1.0, child: child);
    }
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

class StatsTransform extends StatelessWidget {
  final double statsT;
  final Widget child;

  const StatsTransform({required this.statsT, required this.child});

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

