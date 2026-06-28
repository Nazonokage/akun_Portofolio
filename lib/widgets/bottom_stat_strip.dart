import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// ─── Bottom Stat Strip ────────────────────────────────────────────────────
class BottomStatStrip extends StatelessWidget {
  const BottomStatStrip({super.key});

  static const _items = [
    ('3D TILT', 'Matrix4 perspective'),
    ('60 FPS', 'Canvas repaint'),
    ('SPRING', 'Physics engine'),
    ('∞', 'Scroll depth'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
    decoration: glassCardDecoration(
      borderAlpha: 0.09,
      radius: 16,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _items
          .map((e) => AnimatedStatItem(value: e.$1, label: e.$2))
          .toList(),
    ),
  );
}

class AnimatedStatItem extends StatefulWidget {
  final String value, label;
  const AnimatedStatItem({super.key, required this.value, required this.label});

  @override
  State<AnimatedStatItem> createState() => _AnimatedStatItemState();
}

class _AnimatedStatItemState extends State<AnimatedStatItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _t = CurvedAnimation(parent: _ctrl, curve: morphCurve);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) _ctrl.reverse();
      });
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _onTap,
    child: MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _t,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, -5 * _t.value),
          child: Column(
            children: [
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color.lerp(
                    AppColors.neonGlow,
                    AppColors.hologram,
                    _t.value,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.secondaryGlow.withValues(
                    alpha: 0.5 + _t.value * 0.35,
                  ),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

