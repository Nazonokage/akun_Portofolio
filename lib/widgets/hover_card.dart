import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../core/perf.dart';

/// Shared corner-bracket overlay used by project cards and [HoverCard].
class CornerBracketPainter extends CustomPainter {
  final Color color;
  final double opacity;

  CornerBracketPainter(this.color, {this.opacity = 0.55});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const l = 14.0;
    const pad = 6.0;
    final w = size.width;
    final h = size.height;
    for (final path in [
      Path()
        ..moveTo(pad, pad + l)
        ..lineTo(pad, pad)
        ..lineTo(pad + l, pad),
      Path()
        ..moveTo(w - pad - l, pad)
        ..lineTo(w - pad, pad)
        ..lineTo(w - pad, pad + l),
      Path()
        ..moveTo(pad, h - pad - l)
        ..lineTo(pad, h - pad)
        ..lineTo(pad + l, h - pad),
      Path()
        ..moveTo(w - pad - l, h - pad)
        ..lineTo(w - pad, h - pad)
        ..lineTo(w - pad, h - pad - l),
    ]) {
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(CornerBracketPainter old) =>
      old.color != color || old.opacity != opacity;
}

/// Valorant-style hover lift + glow + corner brackets.
/// On mobile browsers, a tap briefly activates the hover state.
class HoverCard extends StatefulWidget {
  final Widget child;
  final Color accent;
  final VoidCallback? onTap;
  final bool enableTapFeedback;

  const HoverCard({
    super.key,
    required this.child,
    required this.accent,
    this.onTap,
    this.enableTapFeedback = true,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;
  bool _tapActive = false;

  bool get _active => _hovered || _tapActive;

  bool get _useTapFeedback =>
      widget.enableTapFeedback && (Perf.isMobileWeb || !kIsWeb);

  void _enter() => setState(() => _hovered = true);
  void _exit() => setState(() => _hovered = false);

  void _handleTap() {
    widget.onTap?.call();
    if (!_useTapFeedback) return;
    setState(() => _tapActive = true);
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _tapActive = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, _active ? -3 : 0, 0),
      decoration: BoxDecoration(
        boxShadow: _active
            ? [
                BoxShadow(
                  color: widget.accent.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.accent.withValues(alpha: _active ? 0.5 : 0.2),
              ),
            ),
            child: widget.child,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: _active
                  ? CustomPaint(
                      painter: CornerBracketPainter(widget.accent),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => _enter(),
      onExit: (_) => _exit(),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap != null || _useTapFeedback ? _handleTap : null,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );
  }
}
