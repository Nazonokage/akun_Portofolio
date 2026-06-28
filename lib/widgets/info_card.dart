import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// ─── Info Card ─────────────────────────────────────────────────────────────
class InfoCard extends StatefulWidget {
  final String icon, title, body;
  final Color accentColor;
  const InfoCard({super.key, 
    required this.icon,
    required this.title,
    required this.body,
    required this.accentColor,
  });

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hover;
  late final Animation<double> _hoverT, _iconScale, _shimmer;
  late final String _titleUpper;

  @override
  void initState() {
    super.initState();
    _titleUpper = widget.title.toUpperCase();
    _hover = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _hoverT = CurvedAnimation(parent: _hover, curve: morphCurve);
    _iconScale = Tween(begin: 1.0, end: 1.28).animate(_hoverT);
    _shimmer = Tween(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _hover, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  void _onTap() {
    _hover.stop();
    _hover.value = 0.0;
    _hover.forward().then((_) {
      if (mounted) _hover.reverse();
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _onTap,
    child: MouseRegion(
      onEnter: (_) => _hover.forward(),
      onExit: (_) => _hover.reverse(),
      child: AnimatedBuilder(
        animation: _hover,
        builder: (_, __) {
          final t = _hoverT.value;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(-t * 2 * math.pi / 180)
              ..translateByDouble(0.0, -t * 5.0, 0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.13 + t * 0.38),
                  width: 1.0 + t * 0.5,
                ),
                color: AppColors.frame.withValues(alpha: 0.32 + t * 0.30),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: t * 0.16),
                    blurRadius: 28 * t,
                    spreadRadius: 2 * t,
                  ),
                  BoxShadow(
                    color: AppColors.background.withValues(alpha: 0.5),
                    offset: Offset(0, 5 * t),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    if (t > 0.01)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: ShimmerPainter(
                              position: _shimmer.value,
                              color: widget.accentColor,
                            ),
                          ),
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Transform.scale(
                              scale: _iconScale.value,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.icon,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: widget.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _titleUpper,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: widget.accentColor,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ),
                            SizeTransition(
                              sizeFactor: _hoverT,
                              axis: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 9,
                                  color: widget.accentColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 1.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.accentColor.withValues(alpha: 0.5),
                                widget.accentColor.withValues(alpha: 0.08),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.body,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(
                              alpha: 0.58 + t * 0.18,
                            ),
                            height: 1.68,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 1.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                widget.accentColor.withValues(alpha: 0.08),
                                widget.accentColor.withValues(alpha: 0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizeTransition(
                          sizeFactor: _hoverT,
                          axisAlignment: -1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Container(
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.accentColor.withValues(alpha: 0.75),
                                    widget.accentColor.withValues(alpha: 0.0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class ShimmerPainter extends CustomPainter {
  final double position;
  final Color color;
  const ShimmerPainter({required this.position, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final x = position * size.width;
    final width = size.width * 0.65;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.10),
            color.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ).createShader(Rect.fromLTWH(x - width / 2, 0, width, size.height)),
    );
  }

  @override
  bool shouldRepaint(ShimmerPainter old) => old.position != position;
}

