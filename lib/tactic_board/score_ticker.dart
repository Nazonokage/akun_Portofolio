import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'floating_board.dart';

// ─── Score Ticker ──────────────────────────────────────────────────────────
class ScoreTicker extends StatelessWidget {
  const ScoreTicker({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: glassCardDecoration(
      borderAlpha: 0.14,
      radius: 14,
      boxShadow: [
        BoxShadow(
          color: AppColors.neonGlow.withValues(alpha: 0.06),
          blurRadius: 20,
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const TeamScore(code: 'FCN', score: '2', color: AppColors.teamA),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              LiveBadge(pulse: 0.0),
              SizedBox(height: 4),
              Text(
                "67'",
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: AppColors.hologram,
                ),
              ),
            ],
          ),
        ),
        const TeamScore(code: 'RKC', score: '1', color: AppColors.teamB),
      ],
    ),
  );
}

class LiveBadge extends StatelessWidget {
  final double pulse;
  const LiveBadge({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.teamB.withValues(alpha: 0.12 + pulse * 0.05),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: AppColors.teamB.withValues(alpha: 0.3 + pulse * 0.2),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.teamB.withValues(alpha: 0.5 + pulse * 0.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.teamB.withValues(alpha: pulse * 0.8),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        Text(
          'LIVE',
          style: TextStyle(
            fontSize: 8,
            color: AppColors.teamB,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class TeamScore extends StatelessWidget {
  final String code, score;
  final Color color;
  const TeamScore({super.key, 
    required this.code,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        code,
        style: TextStyle(
          fontSize: 9,
          color: color.withValues(alpha: 0.7),
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        score,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: color,
          shadows: [
            Shadow(color: color.withValues(alpha: 0.6), blurRadius: 14),
          ],
        ),
      ),
    ],
  );
}

// ─── Board controls (shared portrait + landscape layouts) ─────────────────
class BoardControls extends StatelessWidget {
  final String pulsingLabel;
  final String formationLabel;
  final String formationValue;
  final bool dragMode;
  final bool showHeatmap;
  final bool expanded;
  final VoidCallback onToggleDragMode;
  final VoidCallback onToggleHeatmap;
  final VoidCallback onToggleExpand;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool compact;

  const BoardControls({super.key, 
    required this.pulsingLabel,
    required this.formationLabel,
    required this.formationValue,
    required this.dragMode,
    required this.showHeatmap,
    required this.expanded,
    required this.onToggleDragMode,
    required this.onToggleHeatmap,
    required this.onToggleExpand,
    required this.onUndo,
    required this.onRedo,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconButtons = [
      boardIconBtn(
        dragMode ? Icons.edit_off : Icons.edit,
        dragMode ? AppColors.accent3 : AppColors.neonGlow,
        onToggleDragMode,
        'Edit Mode',
      ),
      boardIconBtn(
        showHeatmap ? Icons.grid_on : Icons.grid_off,
        showHeatmap ? AppColors.gold : AppColors.secondaryGlow,
        onToggleHeatmap,
        'Heatmap',
      ),
      boardIconBtn(
        expanded ? Icons.fullscreen_exit : Icons.fullscreen,
        expanded ? AppColors.gold : AppColors.neonGlow,
        onToggleExpand,
        expanded ? 'Close fullscreen' : 'Expand',
      ),
      if (dragMode) ...[
        boardIconBtn(Icons.undo, AppColors.neonGlow, onUndo, 'Undo'),
        boardIconBtn(Icons.redo, AppColors.neonGlow, onRedo, 'Redo'),
      ],
    ];

    final controls = compact
        ? Wrap(alignment: WrapAlignment.center, spacing: 0, children: iconButtons)
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: iconButtons);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulsingLabel(label: pulsingLabel),
        SizedBox(height: compact ? 8 : 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            readoutChip(label: formationLabel, value: formationValue),
          ],
        ),
        const SizedBox(height: 8),
        controls,
      ],
    );
  }
}

