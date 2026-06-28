import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';

// ─── Stats Panel ────────────────────────────────────────────────────────────
class StatsPanel extends StatefulWidget {
  final String formation;
  const StatsPanel({super.key, required this.formation});

  @override
  State<StatsPanel> createState() => _StatsPanelState();
}

class _StatsPanelState extends State<StatsPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  late final List<Animation<double>> _opacities;
  late final List<Animation<double>> _slides;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _opacities = List.generate(7, (index) {
      final start = (index * 0.1).clamp(0.0, 0.7);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _enter,
        curve: Interval(start, end, curve: morphCurve),
      );
    });
    _slides = _opacities
        .map((curved) => Tween(begin: 20.0, end: 0.0).animate(curved))
        .toList();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _enter.forward();
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Widget _staggered(Widget child, int index) => FadeTransition(
    opacity: _opacities[index],
    child: Transform.translate(
      offset: Offset(0, _slides[index].value),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _staggered(RepaintBoundary(child: const LiveChip()), 0),
      const SizedBox(height: 18),
      _staggered(
        const Text(
          'Formation\nBreakdown',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.08,
          ),
        ),
        1,
      ),
      const SizedBox(height: 8),
      _staggered(
        Text(
          'Drag · tap · switch to analyse\nplayer positioning in 3D.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.secondaryGlow.withValues(alpha: 0.68),
            height: 1.55,
          ),
        ),
        2,
      ),
      const SizedBox(height: 26),
      _staggered(FormationReadoutCard(formation: widget.formation), 3),

      const SizedBox(height: 18),
      _staggered(const MatchBarRow(), 4),
      const SizedBox(height: 18),
      _staggered(TeamLegendRow(), 5),
      const SizedBox(height: 22),
      _staggered(const TacticalNotesCard(), 6),
    ],
  );
}

class FormationReadoutCard extends StatelessWidget {
  final String formation;
  const FormationReadoutCard({super.key, required this.formation});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: glassCardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVE FORMATION',
          style: TextStyle(
            fontSize: 9,
            color: AppColors.hologram,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          formation,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: 'monospace',
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Detected live from player positions on the board.',
          style: TextStyle(
            fontSize: 12,
            height: 1.55,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
      ],
    ),
  );
}

class TeamLegendRow extends StatelessWidget {
  const TeamLegendRow({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: glassCardDecoration(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LegendItem(color: AppColors.gold, label: 'DEF'),
        LegendItem(color: AppColors.hologram, label: 'MID'),
        LegendItem(color: AppColors.teamA, label: 'ATTK'),
      ],
    ),
  );
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.20),
          border: Border.all(color: color.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 8),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          letterSpacing: 1.2,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class TacticalNotesCard extends StatelessWidget {
  const TacticalNotesCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: glassCardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TACTICAL NOTES',
          style: TextStyle(
            fontSize: 9,
            color: AppColors.hologram,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'High press triggers from midfield third. Wide forwards track back to form a 4-5-1 '
          'defensive block. Overlapping fullbacks create width in transition.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.62),
            height: 1.65,
          ),
        ),
      ],
    ),
  );
}

// ─── Match Bar Row ──────────────────────────────────────────────────────────
class MatchBarRow extends StatefulWidget {
  const MatchBarRow({super.key});
  @override
  State<MatchBarRow> createState() => _MatchBarRowState();
}

class _MatchBarRowState extends State<MatchBarRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _curved;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _curved = CurvedAnimation(parent: _ctrl, curve: morphCurve);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _stats = [
    ('Possession', 0.62, 0.38),
    ('Shots on Target', 0.70, 0.30),
    ('Pass Accuracy', 0.82, 0.60),
  ];

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _curved,
    builder: (_, __) {
      final t = _curved.value;
      return Column(
        children: _stats
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DualBar(
                  label: s.$1,
                  aVal: s.$2 * t,
                  bVal: s.$3 * t,
                  rawA: s.$2,
                  rawB: s.$3,
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

class DualBar extends StatelessWidget {
  final String label;
  final double aVal, bVal, rawA, rawB;
  const DualBar({super.key, 
    required this.label,
    required this.aVal,
    required this.bVal,
    required this.rawA,
    required this.rawB,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.secondaryGlow.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              Text(
                '${(rawA * 100).round()}%',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.teamA,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                ' / ',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.grid.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '${(rawB * 100).round()}%',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.teamB,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 5),
      Stack(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grid.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          FractionallySizedBox(
            widthFactor: aVal,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    AppColors.teamA.withValues(alpha: 0.9),
                    AppColors.teamA.withValues(alpha: 0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teamA.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: bVal * 0.4,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.teamB.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

// ─── Live Chip ──────────────────────────────────────────────────────────────
class LiveChip extends StatefulWidget {
  const LiveChip({super.key});
  @override
  State<LiveChip> createState() => _LiveChipState();
}

class _LiveChipState extends State<LiveChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
    animationsPaused.addListener(_syncPause);
  }

  void _syncPause() {
    if (animationsPaused.value) {
      _ctrl.stop();
    } else if (mounted) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    animationsPaused.removeListener(_syncPause);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.neonGlow.withValues(
              alpha: 0.22 + _ctrl.value * 0.38,
            ),
            width: 1.0 + _ctrl.value * 0.45,
          ),
          borderRadius: BorderRadius.circular(5),
          color: AppColors.neonGlow.withValues(
            alpha: 0.03 + _ctrl.value * 0.045,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonGlow.withValues(alpha: _ctrl.value * 0.12),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5.5,
              height: 5.5,
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teamB.withValues(
                  alpha: 0.5 + _ctrl.value * 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teamB.withValues(alpha: _ctrl.value * 0.7),
                    blurRadius: 7,
                  ),
                ],
              ),
            ),
            const Text(
              'LIVE · MATCH ANALYSIS',
              style: TextStyle(fontSize: 9, color: AppColors.neonGlow),
            ),
          ],
        ),
      ),
    ),
  );
}
