import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:visibility_detector/visibility_detector.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';

// ─── Combined Background Painter ──────────────────────────────────────────
class CombinedBgPainter extends CustomPainter {
  final double scroll;
  final double auroraT;
  CombinedBgPainter({required this.scroll, required this.auroraT});

  // Cached shaders for morph background
  ui.Shader? _pitchShader;
  ui.Shader? _vignetteShader;
  double _lastScroll = -1.0;
  double _lastOpacity = -1.0;
  double _lastSOp = -1.0;
  Size? _lastSize;
  int _lastAuroraKey = -1;

  // Cached aurora blobs (offscreen layer)
  ui.Picture? _auroraPicture;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = Curves.easeInOutCubic.transform((scroll / 420).clamp(0.0, 1.0));
    final pT = h * 0.05 + t * h * 0.55;
    final pB = h * 0.52 + t * h * 0.55;
    final pL = w * 0.08;
    final pR = w * 0.92;
    final op = (0.06 - t * 0.04).clamp(0.0, 0.1);
    final sOp = (0.14 - t * 0.10).clamp(0.0, 0.18);
    final pH = pB - pT;
    final pW = pR - pL;

    // ---- Aurora ----
    final sizeChanged = _lastSize != size;
    final auroraKey = (Perf.enableAuroraAnim
        ? (auroraT * (Perf.lightEffects ? 15 : 30)).round()
        : 0);
    if (sizeChanged || _auroraPicture == null || _lastAuroraKey != auroraKey) {
      _lastSize = size;
      _lastAuroraKey = auroraKey;
      final recorder = ui.PictureRecorder();
      final c = Canvas(recorder);
      _drawAurora(c, size);
      _auroraPicture = recorder.endRecording();
    }
    canvas.drawPicture(_auroraPicture!);

    // ---- Morph background ----
    final opChanged = (op - _lastOpacity).abs() > 0.005;
    final sOpChanged = (sOp - _lastSOp).abs() > 0.005;
    final scrollChanged = (scroll - _lastScroll).abs() > 1.0;

    if (sizeChanged || opChanged || sOpChanged || scrollChanged) {
      _lastSize = size;
      _lastOpacity = op;
      _lastSOp = sOp;
      _lastScroll = scroll;
      if (op > 0.001) {
        final pitchRect = Rect.fromLTRB(pL, pT, pR, pB);
        _pitchShader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.neonGlow.withValues(alpha: op * 0.8),
            AppColors.neonGlow.withValues(alpha: op),
            AppColors.neonGlow.withValues(alpha: op * 0.4),
          ],
        ).createShader(pitchRect);
      } else {
        _pitchShader = null;
      }
      _vignetteShader = RadialGradient(
        colors: [
          Colors.transparent,
          AppColors.background.withValues(alpha: 0.78),
        ],
        radius: 0.85,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    }

    if (op > 0.001 && _pitchShader != null) {
      final pitchRect = Rect.fromLTRB(pL, pT, pR, pB);
      final rr = RRect.fromRectAndRadius(pitchRect, const Radius.circular(24));
      canvas.drawRRect(rr, Paint()..shader = _pitchShader!);
      canvas.drawRRect(
        rr,
        Paint()
          ..color = AppColors.neonGlow.withValues(alpha: sOp)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke,
      );
      final midY = pT + pH / 2;
      canvas.drawLine(
        Offset(pL, midY),
        Offset(pR, midY),
        Paint()
          ..color = AppColors.neonGlow.withValues(alpha: sOp * 0.7)
          ..strokeWidth = 0.8,
      );
      canvas.drawCircle(
        Offset(pL + pW / 2, midY),
        pH * 0.16,
        Paint()
          ..color = AppColors.neonGlow.withValues(alpha: sOp * 0.5)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke,
      );
      for (final rect in [
        Rect.fromLTRB(pL, pT + pH * 0.3, pL + pW * 0.2, pB - pH * 0.3),
        Rect.fromLTRB(pR - pW * 0.2, pT + pH * 0.3, pR, pB - pH * 0.3),
      ]) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = AppColors.neonGlow.withValues(alpha: sOp * 0.45)
            ..strokeWidth = 0.7
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // Grid
    final gridPaint = Paint()
      ..color = AppColors.grid.withValues(alpha: 0.07)
      ..strokeWidth = 0.4;
    const step = 64.0;
    final shift = (scroll * 0.2) % step;
    for (double x = -shift; x < w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = -shift; y < h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Vignette
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = _vignetteShader!,
    );
  }

  void _drawAurora(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Rect.fromLTWH(0, 0, w, h);
    final bgShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.background, Color(0xFF030912)],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = bgShader);

    final t = auroraT;
    _drawBlob(
      canvas,
      w * (0.3 + math.sin(t * math.pi * 2) * 0.2),
      h * (0.25 + math.cos(t * math.pi * 1.3) * 0.1),
      w * 0.9,
      h * 0.55,
      const Color(0xFF1A0E3A).withValues(alpha: 0.38 + 0.08 * t),
    );
    _drawBlob(
      canvas,
      w * 0.8 + math.cos(t * math.pi * 1.7) * w * 0.1,
      h * 0.7,
      w * 0.7,
      h * 0.45,
      const Color(0xFF0D2240).withValues(alpha: 0.28),
    );
  }

  void _drawBlob(
    Canvas canvas,
    double cx,
    double cy,
    double rw,
    double rh,
    Color color,
  ) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: rw, height: rh);
    if (Perf.useBlur) {
      canvas.drawOval(
        rect,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    } else {
      canvas.drawOval(
        rect,
        Paint()..color = color.withValues(alpha: color.a * 0.55),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: rw * 0.65,
          height: rh * 0.65,
        ),
        Paint()..color = color.withValues(alpha: color.a * 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(CombinedBgPainter old) =>
      old.scroll != scroll || old.auroraT != auroraT;
}

// ─── Shared top gradient line ─────────────────────────────────────────────
class TopGradientLine extends StatelessWidget {
  const TopGradientLine({super.key});
  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: 36,
    right: 36,
    child: Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.neonGlow.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
    ),
  );
}

// ─── Corner Brackets (cached) ──────────────────────────────────────────────
final List<Widget> cornerBracketsCache = [
  BracketWidget(
    alignment: const Alignment(-1.0, -1.0),
    color: AppColors.neonGlow.withValues(alpha: 0.55),
  ),
  BracketWidget(
    alignment: const Alignment(1.0, -1.0),
    color: AppColors.neonGlow.withValues(alpha: 0.55),
  ),
  BracketWidget(
    alignment: const Alignment(-1.0, 1.0),
    color: AppColors.neonGlow.withValues(alpha: 0.55),
  ),
  BracketWidget(
    alignment: const Alignment(1.0, 1.0),
    color: AppColors.neonGlow.withValues(alpha: 0.55),
  ),
];

class BracketWidget extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  const BracketWidget({super.key, required this.alignment, required this.color});

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: Padding(
      padding: const EdgeInsets.all(9),
      child: SizedBox(
        width: 14,
        height: 14,
        child: CustomPaint(
          painter: BracketPainter(
            alignment.x < 0,
            alignment.y < 0,
            color,
            1.5,
          ),
        ),
      ),
    ),
  );
}

class BracketPainter extends CustomPainter {
  final bool isLeft, isTop;
  final Color color;
  final double w;
  // Removed const constructor to avoid analysis error
  BracketPainter(this.isLeft, this.isTop, this.color, this.w);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? size.width : -size.width;
    final dy = isTop ? size.height : -size.height;
    canvas.drawLine(Offset(x, y), Offset(x + dx * 0.5, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy * 0.5), paint);
  }

  @override
  bool shouldRepaint(BracketPainter old) => false;
}

// ─── Space Particles (with trig lookup table) ────────────────────────────
enum ParticleKind { dot, crosshair, triangle }

class Particle {
  double x,
      y,
      vx,
      vy,
      driftPhaseX,
      driftPhaseY,
      driftAmpX,
      driftAmpY,
      driftFreqX,
      driftFreqY,
      angle,
      angleVel,
      age;
  final ParticleKind kind;
  final double size, opacity, lifespan;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.kind,
    required this.size,
    required this.opacity,
    required this.color,
    required this.angle,
    required this.angleVel,
    required this.lifespan,
    required this.driftPhaseX,
    required this.driftPhaseY,
    required this.driftAmpX,
    required this.driftAmpY,
    required this.driftFreqX,
    required this.driftFreqY,
  }) : age = 0;
}

class TrigTable {
  static const int _size = 256;
  static final List<double> _sinTable = List.generate(
    _size,
    (i) => math.sin(2 * math.pi * i / _size),
  );
  static final List<double> _cosTable = List.generate(
    _size,
    (i) => math.cos(2 * math.pi * i / _size),
  );

  static double sin(double x) =>
      _sinTable[((x / (2 * math.pi) * _size).floor() % _size).toInt()];
  static double cos(double x) =>
      _cosTable[((x / (2 * math.pi) * _size).floor() % _size).toInt()];
}

class SpaceParticles extends StatefulWidget {
  const SpaceParticles({super.key});
  @override
  State<SpaceParticles> createState() => _SpaceParticlesState();
}

class _SpaceParticlesState extends State<SpaceParticles>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<Particle> _particles = [];
  Duration _lastTime = Duration.zero;
  final _rng = math.Random();
  late final ParticleNotifier _notifier;
  bool _visible = true;
  int _frameSkip = 0;
  late final int _count;

  static const _particleColors = [
    AppColors.neonGlow,
    AppColors.hologram,
    AppColors.teamB,
    AppColors.accent2,
    AppColors.secondaryGlow,
    AppColors.accent3,
  ];

  @override
  void initState() {
    super.initState();
    _count = Perf.particleCount;
    _notifier = ParticleNotifier();
    _particles.addAll(List.generate(_count, (_) => _spawn(randomAge: true)));
    _ticker = createTicker(_tick)..start();
  }

  Particle _spawn({bool randomAge = false}) {
    final kind =
        ParticleKind.values[_rng.nextInt(ParticleKind.values.length)];
    final color = _particleColors[_rng.nextInt(_particleColors.length)];
    final lifespan = 12.0 + _rng.nextDouble() * 20.0;
    final p = Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      vx: (_rng.nextDouble() - 0.5) * 0.018,
      vy: (_rng.nextDouble() - 0.5) * 0.012,
      kind: kind,
      color: color,
      lifespan: lifespan,
      size: 0.4 + _rng.nextDouble() * 1.1,
      opacity: 0.06 + _rng.nextDouble() * 0.14,
      angle: _rng.nextDouble() * math.pi * 2,
      angleVel: (_rng.nextDouble() - 0.5) * 0.4,
      driftPhaseX: _rng.nextDouble() * math.pi * 2,
      driftPhaseY: _rng.nextDouble() * math.pi * 2,
      driftAmpX: 0.01 + _rng.nextDouble() * 0.03,
      driftAmpY: 0.008 + _rng.nextDouble() * 0.025,
      driftFreqX: 0.2 + _rng.nextDouble() * 0.5,
      driftFreqY: 0.15 + _rng.nextDouble() * 0.45,
    );
    if (randomAge) p.age = _rng.nextDouble() * lifespan;
    return p;
  }

  void _tick(Duration elapsed) {
    if (!_visible || animationsPaused.value) return;
    if (Perf.lightEffects) {
      _frameSkip++;
      if (_frameSkip.isOdd) return;
    }
    if (_lastTime == Duration.zero) {
      _lastTime = elapsed;
      return;
    }
    final dt = (elapsed - _lastTime).inMicroseconds / 1e6;
    _lastTime = elapsed;
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      p.age += dt;
      if (p.age >= p.lifespan) {
        _particles[i] = _spawn();
        continue;
      }
      p.x +=
          p.vx * dt +
          TrigTable.sin(p.driftPhaseX + p.age * p.driftFreqX * math.pi * 2) *
              p.driftAmpX *
              dt;
      p.y +=
          p.vy * dt +
          TrigTable.cos(p.driftPhaseY + p.age * p.driftFreqY * math.pi * 2) *
              p.driftAmpY *
              dt;
      if (p.x < -0.15) p.x = 1.15;
      if (p.x > 1.15) p.x = -0.15;
      if (p.y < -0.15) p.y = 1.15;
      if (p.y > 1.15) p.y = -0.15;
      p.angle += p.angleVel * dt;
    }
    _notifier.notify();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
    key: const Key('space_particles'),
    onVisibilityChanged: (info) {
      final visible = info.visibleFraction > 0.01;
      if (visible != _visible) {
        _visible = visible;
        if (!_visible) {
          _lastTime = Duration.zero; // avoid jump when resuming
        }
      }
    },
    child: CustomPaint(
      painter: ParticlePainter(particles: _particles, repaint: _notifier),
      child: const SizedBox.expand(),
    ),
  );
}

class ParticleNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  const ParticlePainter({
    required this.particles,
    required ChangeNotifier repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final lf = p.age / p.lifespan;
      final alpha =
          p.opacity *
          (lf / 0.12).clamp(0.0, 1.0) *
          ((1.0 - lf) / 0.12).clamp(0.0, 1.0);
      if (alpha < 0.002) continue;
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.angle);
      _drawKind(canvas, p, alpha);
      canvas.restore();
    }
  }

  Paint _strokePaint(Color c, double s, {double w = 0.8}) => Paint()
    ..color = c
    ..strokeWidth = w * s
    ..style = PaintingStyle.stroke;

  void _drawKind(Canvas canvas, Particle p, double alpha) {
    final c = p.color.withValues(alpha: alpha);
    final s = p.size;
    switch (p.kind) {
      case ParticleKind.dot:
        if (Perf.useBlur) {
          canvas.drawCircle(
            Offset.zero,
            3.5 * s * 2.2,
            Paint()
              ..color = p.color.withValues(alpha: alpha * 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
          );
        } else {
          canvas.drawCircle(
            Offset.zero,
            3.5 * s * 1.8,
            Paint()..color = p.color.withValues(alpha: alpha * 0.18),
          );
        }
        canvas.drawCircle(Offset.zero, 3.5 * s, Paint()..color = c);
      case ParticleKind.crosshair:
        final r = 8.0 * s;
        final lp = _strokePaint(c, s);
        canvas.drawCircle(Offset.zero, r, lp);
        final gap = r * 0.35;
        canvas.drawLine(Offset(-r - 4, 0), Offset(-gap, 0), lp);
        canvas.drawLine(Offset(gap, 0), Offset(r + 4, 0), lp);
        canvas.drawLine(Offset(0, -r - 4), Offset(0, -gap), lp);
        canvas.drawLine(Offset(0, gap), Offset(0, r + 4), lp);
      case ParticleKind.triangle:
        final r = 7.0 * s;
        final path = Path()
          ..moveTo(0, -r)
          ..lineTo(r * 0.87, r * 0.5)
          ..lineTo(-r * 0.87, r * 0.5)
          ..close();
        canvas.drawPath(path, _strokePaint(c, s));
    }
  }

  @override
  bool shouldRepaint(ParticlePainter old) => false;
}

// ─── Scan Line ──────────────────────────────────────────────────────────────
class ScanLine extends StatefulWidget {
  const ScanLine({super.key});

  @override
  State<ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    animationsPaused.addListener(_syncPause);
  }

  void _syncPause() {
    if (animationsPaused.value) {
      _ctrl.stop();
    } else if (mounted) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    animationsPaused.removeListener(_syncPause);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenH,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: ScanLinePainter(progress: _ctrl.value, screenH: screenH),
        ),
      ),
    );
  }
}

class ScanLinePainter extends CustomPainter {
  final double progress, screenH;
  ui.Shader? _cachedShader;
  Size? _lastSize;

  ScanLinePainter({required this.progress, required this.screenH});

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * screenH * 1.3 - screenH * 0.15;
    void drawLine(double dy, double h, double alpha) {
      final rect = Rect.fromLTWH(0, y + dy, size.width, h);
      if (_cachedShader == null || _lastSize != size) {
        _lastSize = size;
        _cachedShader = LinearGradient(
          stops: const [0, 0.25, 0.5, 0.75, 1],
          colors: [
            Colors.transparent,
            AppColors.neonGlow.withValues(alpha: alpha * 0.4),
            AppColors.neonGlow.withValues(alpha: alpha),
            AppColors.neonGlow.withValues(alpha: alpha * 0.4),
            Colors.transparent,
          ],
        ).createShader(rect);
      }
      canvas.drawRect(rect, Paint()..shader = _cachedShader);
    }

    drawLine(0, 2.5, 0.10);
    drawLine(4, 1.0, 0.02);
  }

  @override
  bool shouldRepaint(ScanLinePainter old) => old.progress != progress;
}

