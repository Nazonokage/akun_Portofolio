import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';

/// Single skill rating bar (self-assessed 0–10 style).
class SkillBar extends StatelessWidget {
  final String label;
  final double value;
  final int score;
  final int maxScore;

  const SkillBar({
    super.key,
    required this.label,
    required this.value,
    required this.score,
    this.maxScore = 10,
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
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                '$score/$maxScore',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.teamA,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.grid.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondaryGlow.withValues(alpha: 0.9),
                        AppColors.neonGlow.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGlow.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}

/// Readout chip matching the stats panel visual family.
class ReadoutChip extends StatelessWidget {
  final String label;
  final String value;

  const ReadoutChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => readoutChip(label: label, value: value);
}

/// Animated live-style chip for contact actions.
class ContactChip extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const ContactChip({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  State<ContactChip> createState() => _ContactChipState();
}

class _ContactChipState extends State<ContactChip>
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.neonGlow.withValues(
                      alpha: 0.22 + _ctrl.value * 0.28,
                    ),
                    width: 1.0 + _ctrl.value * 0.35,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.neonGlow.withValues(
                    alpha: 0.03 + _ctrl.value * 0.045,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGlow
                          .withValues(alpha: _ctrl.value * 0.12),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 8,
                        letterSpacing: 2.2,
                        color: AppColors.neonGlow.withValues(alpha: 0.65),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
