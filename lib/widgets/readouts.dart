import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';

/// Single skill rating bar (self-assessed 0–10 style).
class SkillBar extends StatelessWidget {
  final String label;
  final double value;
  final int score;
  final int maxScore;

  const SkillBar(
      {super.key,
      required this.label,
      required this.value,
      required this.score,
      this.maxScore = 10});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      color: AppColors.secondaryGlow.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                      fontFamily: 'monospace')),
              Text('$score/$maxScore',
                  style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.teamA,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 5),
          Stack(children: [
            Container(
                height: 8,
                decoration: BoxDecoration(
                    color: AppColors.grid.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4))),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(colors: [
                    AppColors.secondaryGlow.withValues(alpha: 0.9),
                    AppColors.neonGlow.withValues(alpha: 0.7)
                  ]),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.neonGlow.withValues(alpha: 0.35),
                        blurRadius: 8)
                  ],
                ),
              ),
            ),
          ]),
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
/// [accent] overrides the default neonGlow color — use for resume/special chips.
/// [prefix] optional leading symbol shown before the label (e.g. '↓').
class ContactChip extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color? accent;
  final String? prefix;

  const ContactChip({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.accent,
    this.prefix,
  });

  @override
  State<ContactChip> createState() => _ContactChipState();
}

class _ContactChipState extends State<ContactChip>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    animationsPaused.addListener(_syncPause);
  }

  void _syncPause() {
    if (animationsPaused.value) {
      _pulse.stop();
    } else if (mounted) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    animationsPaused.removeListener(_syncPause);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accent ?? AppColors.neonGlow;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                border: Border.all(
                  color: color.withValues(
                      alpha: _hovered ? 0.75 : 0.22 + _pulse.value * 0.28),
                  width: _hovered ? 1.5 : 1.0 + _pulse.value * 0.35,
                ),
                borderRadius: BorderRadius.circular(6),
                color: color.withValues(
                    alpha: _hovered ? 0.10 : 0.03 + _pulse.value * 0.045),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(
                        alpha: _hovered ? 0.20 : _pulse.value * 0.12),
                    blurRadius: _hovered ? 18 : 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label row with optional prefix
                  Row(children: [
                    if (widget.prefix != null) ...[
                      Text(widget.prefix!,
                          style: TextStyle(
                              fontSize: 9,
                              color: color,
                              fontFamily: 'monospace')),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 2.2,
                          color: color.withValues(alpha: _hovered ? 1.0 : 0.65),
                          fontFamily: 'monospace'),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    widget.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color:
                          Colors.white.withValues(alpha: _hovered ? 1.0 : 0.88),
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
}
