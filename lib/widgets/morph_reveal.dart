import 'package:flutter/material.dart';

// ─── Morph Reveal ──────────────────────────────────────────────────────────
class MorphReveal extends StatefulWidget {
  final Widget child;
  final ValueNotifier<double> offsetNotifier;
  final double triggerAt;
  final int delayMs;
  const MorphReveal({
    required this.child,
    required this.offsetNotifier,
    required this.triggerAt,
    this.delayMs = 0,
  });

  @override
  State<MorphReveal> createState() => _MorphRevealState();
}

class _MorphRevealState extends State<MorphReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.offsetNotifier.addListener(_checkTrigger);
    _checkTrigger();
  }

  void _checkTrigger() {
    if (!_visible && widget.offsetNotifier.value >= widget.triggerAt) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  void dispose() {
    widget.offsetNotifier.removeListener(_checkTrigger);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: _visible ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 750),
    curve: Curves.easeOut,
    child: AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.08),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOut,
      child: widget.child,
    ),
  );
}

