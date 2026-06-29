import 'package:flutter/material.dart';

import '../core/perf.dart';

class MorphReveal extends StatefulWidget {
  final Widget child;
  final ValueNotifier<double> offsetNotifier;
  final double triggerAt;
  final int delayMs;

  const MorphReveal({
    super.key,
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
  bool _pending = false;

  @override
  void initState() {
    super.initState();
    widget.offsetNotifier.addListener(_checkTrigger);
    _checkTrigger();
  }

  @override
  void didUpdateWidget(covariant MorphReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offsetNotifier != widget.offsetNotifier) {
      oldWidget.offsetNotifier.removeListener(_checkTrigger);
      widget.offsetNotifier.addListener(_checkTrigger);
      _checkTrigger();
    }
  }

  void _checkTrigger() {
    if (_visible || _pending) return;
    if (widget.offsetNotifier.value < widget.triggerAt) return;

    _pending = true;
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      _pending = false;
      if (mounted && widget.offsetNotifier.value >= widget.triggerAt) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    widget.offsetNotifier.removeListener(_checkTrigger);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Perf.isMobileWeb || Perf.reduceMotion) {
      return Visibility(
        visible: _visible,
        maintainState: true,
        maintainAnimation: false,
        maintainSize: false,
        child: widget.child,
      );
    }
    return AnimatedOpacity(
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
}
