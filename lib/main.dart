import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:visibility_detector/visibility_detector.dart';

void main() => runApp(const TacticBoardApp());

// ─── Palette ────────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF04090F);
  static const surface = Color(0xFF081422);
  static const frame = Color(0xFF0C1E36);
  static const grid = Color(0xFF0E3A50);
  static const neonGlow = Color(0xFF52EBD9);
  static const hologram = Color(0xFF44C5B8);
  static const secondaryGlow = Color(0xFF43AAA4);
  static const teamA = Color(0xFF52EBD9);
  static const teamB = Color(0xFFFF4D6D);
  static const accent2 = Color(0xFF6C63FF);
  static const accent3 = Color(0xFFFF9F43);
  static const gold = Color(0xFFFFD166);
}

const _morphCurve = Cubic(0.16, 1.0, 0.3, 1.0);
const _snapCurve = Cubic(0.22, 1.0, 0.36, 1.0);

double _lerp(double a, double b, double t) => a + (b - a) * t;

// ─── Shared Text Layout Cache (capped LRU) ────────────────────────────────
class _LRUTextCache {
  static const _maxSize = 50;
  static final _cache = <String, TextPainter>{};
  static final _order = <String>[];

  static TextPainter get(String text, TextStyle style) {
    final key = '$text-${style.hashCode}';
    if (_cache.containsKey(key)) {
      _order.remove(key);
      _order.add(key);
      return _cache[key]!;
    }
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    if (_cache.length >= _maxSize) {
      final oldest = _order.removeAt(0);
      _cache.remove(oldest);
    }
    _cache[key] = painter;
    _order.add(key);
    return painter;
  }

  static void clear() {
    _cache.clear();
    _order.clear();
  }
}

TextPainter _layoutText(String text, TextStyle style) =>
    _LRUTextCache.get(text, style);

void _paintText(Canvas canvas, String text, TextStyle style, Offset offset) {
  _layoutText(text, style).paint(canvas, offset);
}

// ─── Formation Detection ──────────────────────────────────────────────────
class FormationAnalyzer {
  static String detect(List<Offset> positions, double pitchWidth) {
    if (positions.length < 10) return "4-2-3-1";
    final nonGk = positions.skip(1).toList();
    if (nonGk.length < 9) return "4-2-3-1";

    final xValues = (List<Offset>.from(
      nonGk,
    )..sort((a, b) => a.dx.compareTo(b.dx))).map((p) => p.dx).toList();
    final clusters = _kMeansOptimized(xValues, 3);
    final counts = List.filled(3, 0);
    for (final idx in clusters) {
      counts[idx]++;
    }

    final avgs = _clusterAvgs(xValues, clusters, 3);
    final order = List.generate(3, (i) => i)
      ..sort((a, b) => avgs[a].compareTo(avgs[b]));
    return '${counts[order[0]]}-${counts[order[1]]}-${counts[order[2]]}';
  }

  static List<double> getBandAveragesX(
    List<Offset> positions,
    double pitchWidth,
  ) {
    if (positions.length < 10) return [pitchWidth * 0.33, pitchWidth * 0.66];
    final nonGk = positions.skip(1).toList();
    if (nonGk.length < 9) return [pitchWidth * 0.33, pitchWidth * 0.66];

    final xValues = (List<Offset>.from(
      nonGk,
    )..sort((a, b) => a.dx.compareTo(b.dx))).map((p) => p.dx).toList();
    final avgs = _clusterAvgs(xValues, _kMeansOptimized(xValues, 3), 3)..sort();
    return avgs;
  }

  static List<double> _clusterAvgs(
    List<double> data,
    List<int> labels,
    int k,
  ) => List.generate(k, (i) {
    double sum = 0.0;
    int count = 0;
    for (int j = 0; j < data.length; j++) {
      if (labels[j] == i) {
        sum += data[j];
        count++;
      }
    }
    return count > 0 ? sum / count : 0.0;
  });

  static List<int> _kMeansOptimized(List<double> data, int k) {
    if (data.isEmpty) return [];
    final minVal = data.reduce(math.min);
    final step = (data.reduce(math.max) - minVal) / (k - 1);
    var centroids = List.generate(k, (i) => minVal + i * step);
    final labels = List.filled(data.length, 0);
    bool changed = true;
    while (changed) {
      changed = false;
      for (int i = 0; i < data.length; i++) {
        double minDist = double.infinity;
        int best = 0;
        for (int j = 0; j < k; j++) {
          final dist = (data[i] - centroids[j]).abs();
          if (dist < minDist) {
            minDist = dist;
            best = j;
          }
        }
        if (labels[i] != best) {
          labels[i] = best;
          changed = true;
        }
      }
      final sums = List.filled(k, 0.0);
      final counts = List.filled(k, 0);
      for (int i = 0; i < data.length; i++) {
        final label = labels[i];
        sums[label] += data[i];
        counts[label]++;
      }
      for (int j = 0; j < k; j++) {
        if (counts[j] > 0) centroids[j] = sums[j] / counts[j];
      }
    }
    return labels;
  }
}

// ─── Position / Jersey Data ──────────────────────────────────────────────
const _positionLabels = [
  'GK',
  'LB',
  'CB',
  'CB',
  'RB',
  'CDM',
  'CDM',
  'LW',
  'CAM',
  'RW',
  'ST',
];
const _jerseyNumbers = [1, 2, 3, 4, 5, 6, 8, 7, 10, 11, 9];

final _defaultPositions = [
  (w, h) => Offset(w * 0.07, h / 2),
  (w, h) => Offset(w * 0.21, h * 0.10),
  (w, h) => Offset(w * 0.21, h * 0.38),
  (w, h) => Offset(w * 0.21, h * 0.62),
  (w, h) => Offset(w * 0.21, h * 0.90),
  (w, h) => Offset(w * 0.36, h * 0.38),
  (w, h) => Offset(w * 0.36, h * 0.62),
  (w, h) => Offset(w * 0.50, h * 0.22),
  (w, h) => Offset(w * 0.50, h / 2),
  (w, h) => Offset(w * 0.50, h * 0.78),
  (w, h) => Offset(w * 0.62, h / 2),
];

// ─── App ──────────────────────────────────────────────────────────────────
class TacticBoardApp extends StatelessWidget {
  const TacticBoardApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
    ),
    home: const TacticBoardScreen(),
  );
}

// ─── Main Screen ──────────────────────────────────────────────────────────
class TacticBoardScreen extends StatefulWidget {
  const TacticBoardScreen({super.key});
  @override
  State<TacticBoardScreen> createState() => _TacticBoardScreenState();
}

class _TacticBoardScreenState extends State<TacticBoardScreen>
    with TickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0);
  final ValueNotifier<double> _rawOffset = ValueNotifier<double>(0);
  final ValueNotifier<bool> _editModeNotifier = ValueNotifier<bool>(false);

  late final AnimationController _ghostCtrl, _auroraCtrl, _entryCtrl;
  late final Animation<double> _entryCurved; // cached CurvedAnimation
  final ValueNotifier<String> _formationNotifier = ValueNotifier<String>(
    "4-2-3-1",
  );

  @override
  void initState() {
    super.initState();
    _ghostCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _auroraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _entryCurved = CurvedAnimation(parent: _entryCtrl, curve: _morphCurve);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _entryCtrl.forward();
    });

    _scroll.addListener(() {
      final offset = _scroll.offset;
      final p = (offset / 420).clamp(0.0, 1.0);
      _scrollProgress.value = p;
      _rawOffset.value = offset;
      _ghostCtrl.value = ((offset - 280) / 180).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _ghostCtrl.dispose();
    _auroraCtrl.dispose();
    _entryCtrl.dispose();
    _formationNotifier.dispose();
    _editModeNotifier.dispose();
    _LRUTextCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Combined background painter (aurora + morph + grid + vignette)
          Positioned.fill(
            child: RepaintBoundary(
              child: ValueListenableBuilder<double>(
                valueListenable: _rawOffset,
                builder: (_, offset, __) => AnimatedBuilder(
                  animation: _auroraCtrl,
                  builder: (_, __) => CustomPaint(
                    painter: _CombinedBgPainter(
                      scroll: offset,
                      auroraT: _auroraCtrl.value,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(child: _SpaceParticles()),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _entryCtrl,
                builder: (_, __) {
                  final t = _entryCtrl.value;
                  if (t > 0.35) return const SizedBox.shrink();
                  final alpha = (1.0 - t / 0.35).clamp(0.0, 1.0) * 0.055;
                  return Container(
                    color: AppColors.neonGlow.withValues(alpha: alpha),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ValueListenableBuilder<double>(
                  valueListenable: _scrollProgress,
                  builder: (_, progress, __) =>
                      _ScrollProgressBar(progress: progress),
                ),
              ),
            ),
          ),
          SafeArea(
            child: ValueListenableBuilder<bool>(
              valueListenable: _editModeNotifier,
              builder: (_, isEditing, child) => SingleChildScrollView(
                controller: _scroll,
                physics: isEditing
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                child: child,
              ),
              child: AnimatedBuilder(
                animation: _entryCtrl,
                builder: (_, child) {
                  final t = _entryCurved.value;
                  return FadeTransition(
                    opacity: AlwaysStoppedAnimation(t.clamp(0.0, 1.0)),
                    child: Transform.translate(
                      offset: Offset(0, _lerp(40, 0, t)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    _HeroSection(
                      scrollProgressNotifier: _scrollProgress,
                      formationNotifier: _formationNotifier,
                      editModeNotifier: _editModeNotifier,
                    ),
                    _InfoSection(rawOffsetNotifier: _rawOffset),
                    // Extra bottom spacer so the scroll view has more vertical depth
                    // on all screen sizes.
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(child: _ScanLine()),
          ),
        ],
      ),
    );
  }
}

// ─── Scroll Progress Bar ──────────────────────────────────────────────────
class _ScrollProgressBar extends StatelessWidget {
  final double progress;
  const _ScrollProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.frame.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonGlow.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGlow.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.compare_arrows, color: AppColors.neonGlow, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.grid.withValues(alpha: 0.3),
                color: AppColors.neonGlow,
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.neonGlow,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Combined Background Painter ──────────────────────────────────────────
class _CombinedBgPainter extends CustomPainter {
  final double scroll;
  final double auroraT;
  _CombinedBgPainter({required this.scroll, required this.auroraT});

  // Cached shaders for morph background
  ui.Shader? _pitchShader;
  ui.Shader? _vignetteShader;
  double _lastScroll = -1.0;
  double _lastOpacity = -1.0;
  double _lastSOp = -1.0;
  Size? _lastSize;

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
    if (sizeChanged || _auroraPicture == null) {
      _lastSize = size;
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
    canvas.drawOval(
      rect,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  @override
  bool shouldRepaint(_CombinedBgPainter old) =>
      old.scroll != scroll || old.auroraT != auroraT;
}

// ─── Ghost Board Mini ──────────────────────────────────────────────────────
class _GhostBoardMini extends StatefulWidget {
  const _GhostBoardMini();
  @override
  State<_GhostBoardMini> createState() => _GhostBoardMiniState();
}

class _GhostBoardMiniState extends State<_GhostBoardMini>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: 336,
        height: 252,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppColors.frame.withValues(alpha: 0.6),
          border: Border.all(
            color: AppColors.neonGlow.withValues(alpha: 0.35),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonGlow.withValues(
                alpha: 0.25 + _pulse.value * 0.12,
              ),
              blurRadius: 24,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: AppColors.accent2.withValues(alpha: 0.08),
              blurRadius: 60,
              spreadRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              ..._cornerBrackets(AppColors.neonGlow.withValues(alpha: 0.55)),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: CustomPaint(
                    size: const Size(308, 224),
                    painter: _GhostPitchPainter(pulse: _pulse.value),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _HoloPainter(specularX: 0.35, specularY: 0.4),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 14,
                child: Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 2.5,
                    color: AppColors.teamB.withValues(
                      alpha: 0.65 + _pulse.value * 0.35,
                    ),
                  ),
                ),
              ),
              const _TopGradientLine(),
            ],
          ),
        ),
      ),
    ),
  );
}

// ─── Shared top gradient line ─────────────────────────────────────────────
class _TopGradientLine extends StatelessWidget {
  const _TopGradientLine();
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
final List<Widget> _cornerBracketsCache = [
  _BracketWidget(
    alignment: const Alignment(-1.0, -1.0),
    color: AppColors.neonGlow.withValues(alpha: 0.55),
  ),
  _BracketWidget(
    alignment: const Alignment(1.0, -1.0),
    color: AppColors.neonGlow.withValues(alpha: 0.55),
  ),
  _BracketWidget(
    alignment: const Alignment(-1.0, 1.0),
    color: AppColors.neonGlow.withValues(alpha: 0.55),
  ),
  _BracketWidget(
    alignment: const Alignment(1.0, 1.0),
    color: AppColors.neonGlow.withValues(alpha: 0.55),
  ),
];

List<Widget> _cornerBrackets(Color color) => _cornerBracketsCache;

class _BracketWidget extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  const _BracketWidget({required this.alignment, required this.color});

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: Padding(
      padding: const EdgeInsets.all(9),
      child: SizedBox(
        width: 14,
        height: 14,
        child: CustomPaint(
          painter: _BracketPainter(
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

class _BracketPainter extends CustomPainter {
  final bool isLeft, isTop;
  final Color color;
  final double w;
  // Removed const constructor to avoid analysis error
  _BracketPainter(this.isLeft, this.isTop, this.color, this.w);

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
  bool shouldRepaint(_BracketPainter old) => false;
}

// ─── Ghost Pitch Painter ──────────────────────────────────────────────────
class _GhostPitchPainter extends CustomPainter {
  final double pulse;
  const _GhostPitchPainter({required this.pulse});

  Paint _lp(double alpha, {double width = 1.0}) => Paint()
    ..color = AppColors.neonGlow.withValues(alpha: alpha)
    ..strokeWidth = width
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size sz) {
    final w = sz.width;
    final h = sz.height;
    for (int i = 0; i < 7; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * h / 7, w, h / 7),
        Paint()
          ..color = AppColors.neonGlow.withValues(
            alpha: i.isEven ? 0.025 : 0.040,
          ),
      );
    }
    final r = Rect.fromLTWH(0, 0, w, h);
    final rr7 = RRect.fromRectAndRadius(r, const Radius.circular(7));
    final rr8 = RRect.fromRectAndRadius(r, const Radius.circular(8));
    canvas.drawRRect(
      rr8,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.neonGlow.withValues(alpha: 0.06 + pulse * 0.03),
            AppColors.background.withValues(alpha: 0.3),
          ],
        ).createShader(r),
    );
    canvas.drawRRect(rr7, _lp(0.52, width: 1.6));
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), _lp(0.22));
    canvas.drawCircle(Offset(w / 2, h / 2), 34, _lp(0.16 + pulse * 0.10));
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      2.5 + pulse,
      Paint()
        ..color = AppColors.neonGlow.withValues(alpha: 0.60 + pulse * 0.22),
    );
    canvas.drawRect(Rect.fromLTWH(0, h * 0.30, 54, h * 0.40), _lp(0.20));
    canvas.drawRect(Rect.fromLTWH(w - 54, h * 0.30, 54, h * 0.40), _lp(0.20));
    canvas.drawRect(
      Rect.fromLTWH(-3, h * 0.41, 6, h * 0.18),
      _lp(0.65, width: 1.6),
    );
    canvas.drawRect(
      Rect.fromLTWH(w - 3, h * 0.41, 6, h * 0.18),
      _lp(0.65, width: 1.6),
    );

    final posA = List.generate(11, (i) => _defaultPositions[i](w, h));
    final pulseR = 5.4 + pulse * 1.8;
    for (int i = 0; i < posA.length; i++) {
      _drawPlayer(
        canvas,
        posA[i],
        (i % 3 == 0) ? pulseR : 5.4,
        AppColors.teamA,
        pulse,
        _jerseyNumbers[i],
      );
    }
  }

  void _drawPlayer(
    Canvas canvas,
    Offset pos,
    double r,
    Color color,
    double p,
    int num,
  ) {
    canvas.drawCircle(
      pos,
      r + 5,
      Paint()..color = color.withValues(alpha: 0.055 + p * 0.065),
    );
    canvas.drawCircle(
      pos,
      r + 2.5,
      Paint()..color = color.withValues(alpha: 0.14 + p * 0.10),
    );
    canvas.drawCircle(pos, r, Paint()..color = color.withValues(alpha: 0.92));
    final np = _layoutText(
      '$num',
      const TextStyle(
        color: AppColors.background,
        fontSize: 5.5,
        fontWeight: FontWeight.w900,
      ),
    );
    np.paint(canvas, Offset(pos.dx - np.width / 2, pos.dy - np.height / 2));
  }

  @override
  bool shouldRepaint(_GhostPitchPainter old) => old.pulse != pulse;
}

// ─── Space Particles (with trig lookup table) ────────────────────────────
enum _ParticleKind { dot, crosshair, triangle }

class _Particle {
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
  final _ParticleKind kind;
  final double size, opacity, lifespan;
  final Color color;

  _Particle({
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

class _TrigTable {
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

class _SpaceParticles extends StatefulWidget {
  const _SpaceParticles();
  @override
  State<_SpaceParticles> createState() => _SpaceParticlesState();
}

class _SpaceParticlesState extends State<_SpaceParticles>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_Particle> _particles = [];
  Duration _lastTime = Duration.zero;
  final _rng = math.Random();
  static const _count = 16;
  late final _ParticleNotifier _notifier;
  bool _visible = true;

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
    _notifier = _ParticleNotifier();
    _particles.addAll(List.generate(_count, (_) => _spawn(randomAge: true)));
    _ticker = createTicker(_tick)..start();
  }

  _Particle _spawn({bool randomAge = false}) {
    final kind =
        _ParticleKind.values[_rng.nextInt(_ParticleKind.values.length)];
    final color = _particleColors[_rng.nextInt(_particleColors.length)];
    final lifespan = 12.0 + _rng.nextDouble() * 20.0;
    final p = _Particle(
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
    if (!_visible) return;
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
          _TrigTable.sin(p.driftPhaseX + p.age * p.driftFreqX * math.pi * 2) *
              p.driftAmpX *
              dt;
      p.y +=
          p.vy * dt +
          _TrigTable.cos(p.driftPhaseY + p.age * p.driftFreqY * math.pi * 2) *
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
      painter: _ParticlePainter(particles: _particles, repaint: _notifier),
      child: const SizedBox.expand(),
    ),
  );
}

class _ParticleNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  const _ParticlePainter({
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

  void _drawKind(Canvas canvas, _Particle p, double alpha) {
    final c = p.color.withValues(alpha: alpha);
    final s = p.size;
    switch (p.kind) {
      case _ParticleKind.dot:
        canvas.drawCircle(
          Offset.zero,
          3.5 * s * 2.2,
          Paint()
            ..color = p.color.withValues(alpha: alpha * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(Offset.zero, 3.5 * s, Paint()..color = c);
      case _ParticleKind.crosshair:
        final r = 8.0 * s;
        final lp = _strokePaint(c, s);
        canvas.drawCircle(Offset.zero, r, lp);
        final gap = r * 0.35;
        canvas.drawLine(Offset(-r - 4, 0), Offset(-gap, 0), lp);
        canvas.drawLine(Offset(gap, 0), Offset(r + 4, 0), lp);
        canvas.drawLine(Offset(0, -r - 4), Offset(0, -gap), lp);
        canvas.drawLine(Offset(0, gap), Offset(0, r + 4), lp);
      case _ParticleKind.triangle:
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
  bool shouldRepaint(_ParticlePainter old) => false;
}

// ─── Scan Line ──────────────────────────────────────────────────────────────
class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
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
          painter: _ScanLinePainter(progress: _ctrl.value, screenH: screenH),
        ),
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double progress, screenH;
  ui.Shader? _cachedShader;
  Size? _lastSize;

  _ScanLinePainter({required this.progress, required this.screenH});

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
  bool shouldRepaint(_ScanLinePainter old) => old.progress != progress;
}

// ─── Hero Section ─────────────────────────────────────────────────────────
class _HeroSection extends StatefulWidget {
  final ValueNotifier<double> scrollProgressNotifier;
  final ValueNotifier<String> formationNotifier;
  final ValueNotifier<bool> editModeNotifier;
  const _HeroSection({
    required this.scrollProgressNotifier,
    required this.formationNotifier,
    required this.editModeNotifier,
  });

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  String _currentFormation = "4-2-3-1";

  void _onFormationChanged(String newFormation) {
    if (_currentFormation == newFormation) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _currentFormation = newFormation);
        widget.formationNotifier.value = newFormation;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final isLandscape = screenWidth > screenHeight;
    final isWide = screenWidth > 700 || (isLandscape && screenWidth > 500);

    return ValueListenableBuilder<double>(
      valueListenable: widget.scrollProgressNotifier,
      builder: (_, scrollProgress, child) {
        final boardT = _snapCurve.transform(
          (scrollProgress / 0.6).clamp(0.0, 1.0),
        );
        final statsT = _snapCurve.transform(
          ((scrollProgress - 0.15) / 0.75).clamp(0.0, 1.0),
        );

        Widget board = _BoardTransform(
          boardT: boardT,
          isLandscape: isLandscape,
          child: Center(
            child: FloatingTacticBoard(
              onFormationChanged: _onFormationChanged,
              editModeNotifier: widget.editModeNotifier,
            ),
          ),
        );

        Widget stats = _StatsTransform(
          statsT: statsT,
          child: StatsPanel(formation: _currentFormation),
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 36 : 20,
            vertical: isWide ? 36 : 28,
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: board),
                    const SizedBox(width: 36),
                    Expanded(flex: 4, child: stats),
                  ],
                )
              : Column(children: [board, const SizedBox(height: 36), stats]),
        );
      },
    );
  }
}

class _BoardTransform extends StatelessWidget {
  final double boardT;
  final bool isLandscape;
  final Widget child;

  const _BoardTransform({
    required this.boardT,
    required this.isLandscape,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLandscape) {
      return Opacity(opacity: 1.0, child: child);
    }
    final opacity = (1.0 - boardT * 0.7).clamp(0.0, 1.0);
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0009)
        ..translateByDouble(0.0, boardT * -28.0, 0.0, 1.0)
        ..rotateX(boardT * 36.0 * math.pi / 180)
        ..scaleByDouble(1.0 - boardT * 0.13, 1.0 - boardT * 0.13, 1.0, 1.0),
      child: Opacity(opacity: opacity, child: child),
    );
  }
}

class _StatsTransform extends StatelessWidget {
  final double statsT;
  final Widget child;

  const _StatsTransform({required this.statsT, required this.child});

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - statsT * 0.3).clamp(0.0, 1.0);
    return Transform(
      alignment: Alignment.topCenter,
      transform: Matrix4.identity()
        ..translateByDouble(0.0, statsT * -12.0, 0.0, 1.0)
        ..scaleByDouble(1.0 - statsT * 0.05, 1.0 - statsT * 0.05, 1.0, 1.0),
      child: Opacity(opacity: opacity, child: child),
    );
  }
}

// ─── Info Section ──────────────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;
  const _InfoSection({required this.rawOffsetNotifier});

  static const _cardData = [
    (
      icon: '⟳',
      title: 'Drag to Tilt',
      body:
          'Pan on the holographic board to rotate in 3D space. Release and it snaps back with spring physics.',
      accent: AppColors.neonGlow,
      delay: 60,
    ),
    (
      icon: '↕',
      title: 'Scroll to Dive',
      body:
          'Scrolling pitches the board forward — like leaning over a tactical table. The ghost follows depth.',
      accent: AppColors.hologram,
      delay: 120,
    ),
    (
      icon: '◉',
      title: 'Tap for Position',
      body:
          'Tap any player dot to see their position label like [GK], [CDM], [ST]. Double-tap the board to enter drag-edit mode.',
      accent: AppColors.teamB,
      delay: 180,
    ),
    (
      icon: '⬡',
      title: 'Edit Mode',
      body:
          'Double-tap the board to enter edit mode. Drag players to reposition them freely on the pitch.',
      accent: AppColors.accent2,
      delay: 240,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.neonGlow.withValues(alpha: 0.12)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            _MorphReveal(
              offsetNotifier: rawOffsetNotifier,
              triggerAt: 200,
              child: Text(
                '── ABOUT THIS BOARD',

                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.neonGlow.withValues(alpha: 0.45),
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final cards = _cardData
                    .map(
                      (d) => _MorphReveal(
                        offsetNotifier: rawOffsetNotifier,
                        triggerAt: 280,
                        delayMs: d.delay,
                        child: _InfoCard(
                          icon: d.icon,
                          title: d.title,
                          body: d.body,
                          accentColor: d.accent,
                        ),
                      ),
                    )
                    .toList();

                if (isWide) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 16),
                          Expanded(child: cards[1]),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: cards[2]),
                          const SizedBox(width: 16),
                          Expanded(child: cards[3]),
                        ],
                      ),
                    ],
                  );
                }
                return Column(
                  children:
                      cards
                          .expand((c) => [c, const SizedBox(height: 16)])
                          .toList()
                        ..removeLast(),
                );
              },
            ),
            const SizedBox(height: 44),
            _MorphReveal(
              offsetNotifier: rawOffsetNotifier,
              triggerAt: 360,
              delayMs: 100,
              child: const _BottomStatStrip(),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// ─── Morph Reveal ──────────────────────────────────────────────────────────
class _MorphReveal extends StatefulWidget {
  final Widget child;
  final ValueNotifier<double> offsetNotifier;
  final double triggerAt;
  final int delayMs;
  const _MorphReveal({
    required this.child,
    required this.offsetNotifier,
    required this.triggerAt,
    this.delayMs = 0,
  });

  @override
  State<_MorphReveal> createState() => _MorphRevealState();
}

class _MorphRevealState extends State<_MorphReveal> {
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

// ─── Info Card ─────────────────────────────────────────────────────────────
class _InfoCard extends StatefulWidget {
  final String icon, title, body;
  final Color accentColor;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.accentColor,
  });

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard>
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
    _hoverT = CurvedAnimation(parent: _hover, curve: _morphCurve);
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
                            painter: _ShimmerPainter(
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

class _ShimmerPainter extends CustomPainter {
  final double position;
  final Color color;
  const _ShimmerPainter({required this.position, required this.color});

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
  bool shouldRepaint(_ShimmerPainter old) => old.position != position;
}

// ─── Bottom Stat Strip ────────────────────────────────────────────────────
class _BottomStatStrip extends StatelessWidget {
  const _BottomStatStrip();

  static const _items = [
    ('3D TILT', 'Matrix4 perspective'),
    ('60 FPS', 'Canvas repaint'),
    ('SPRING', 'Physics engine'),
    ('∞', 'Scroll depth'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.neonGlow.withValues(alpha: 0.09)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.frame.withValues(alpha: 0.55),
          AppColors.grid.withValues(alpha: 0.18),
        ],
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _items
          .map((e) => _AnimatedStatItem(value: e.$1, label: e.$2))
          .toList(),
    ),
  );
}

class _AnimatedStatItem extends StatefulWidget {
  final String value, label;
  const _AnimatedStatItem({required this.value, required this.label});

  @override
  State<_AnimatedStatItem> createState() => _AnimatedStatItemState();
}

class _AnimatedStatItemState extends State<_AnimatedStatItem>
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
    _t = CurvedAnimation(parent: _ctrl, curve: _morphCurve);
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

// ─── Score Ticker ──────────────────────────────────────────────────────────
class _ScoreTicker extends StatelessWidget {
  const _ScoreTicker();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.neonGlow.withValues(alpha: 0.14)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.frame.withValues(alpha: 0.90),
          AppColors.grid.withValues(alpha: 0.45),
        ],
      ),
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
        const _TeamScore(code: 'FCN', score: '2', color: AppColors.teamA),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              _LiveBadge(pulse: 0.0),
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
        const _TeamScore(code: 'RKC', score: '1', color: AppColors.teamB),
      ],
    ),
  );
}

class _LiveBadge extends StatelessWidget {
  final double pulse;
  const _LiveBadge({required this.pulse});

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

class _TeamScore extends StatelessWidget {
  final String code, score;
  final Color color;
  const _TeamScore({
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

// ─── Floating Tactic Board ──────────────────────────────────────────────────
class FloatingTacticBoard extends StatefulWidget {
  final ValueChanged<String>? onFormationChanged;
  final ValueNotifier<bool>? editModeNotifier;
  const FloatingTacticBoard({
    super.key,
    this.onFormationChanged,
    this.editModeNotifier,
  });

  @override
  State<FloatingTacticBoard> createState() => _FloatingTacticBoardState();
}

class _FloatingTacticBoardState extends State<FloatingTacticBoard>
    with TickerProviderStateMixin {
  late final AnimationController _levitate, _pulse, _formAnim, _passAnim;
  bool _dragMode = false, _showHeatmap = false, _expanded = false;
  int? _selectedPlayer;
  List<Offset?> _customPositions = List.filled(11, null);
  List<List<Offset?>> _history = [];
  int _historyIndex = -1;
  String _currentFormation = "4-2-3-1";

  @override
  void initState() {
    super.initState();
    _levitate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _formAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _passAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 20000),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recomputeFormation();
      _notifyFormationChanged();
    });
  }

  @override
  void dispose() {
    _levitate.dispose();
    _pulse.dispose();
    _formAnim.dispose();
    _passAnim.dispose();
    super.dispose();
  }

  void _pushHistory() {
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }
    _history.add(List.from(_customPositions));
    if (_history.length > 20) _history.removeAt(0);
    _historyIndex = _history.length - 1;
  }

  void _undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      setState(() {
        _customPositions = List.from(_history[_historyIndex]);
        _notifyFormationChanged();
      });
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      setState(() {
        _customPositions = List.from(_history[_historyIndex]);
        _notifyFormationChanged();
      });
    }
  }

  void _notifyFormationChanged() {
    _recomputeFormation();
    final f = _cachedFormation;
    if (_currentFormation != f) {
      _currentFormation = f;
      widget.onFormationChanged?.call(f);
    }
  }

  void _onPlayerTapped(int? index) {
    setState(() => _selectedPlayer = (_selectedPlayer == index) ? null : index);
  }

  void _toggleDragMode() {
    setState(() {
      _dragMode = !_dragMode;
      if (_dragMode) _pushHistory();
      _selectedPlayer = null;
    });
    widget.editModeNotifier?.value = _dragMode;
  }

  void _toggleHeatmap() => setState(() => _showHeatmap = !_showHeatmap);
  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (!_expanded && _dragMode) {
        _dragMode = false;
        _selectedPlayer = null;
      }
    });
    widget.editModeNotifier?.value = _dragMode;
  }

  void _onPlayerDragged(int index, Offset newPos) {
    if (index == 0) return;
    setState(() {
      _customPositions[index] = newPos;
      _notifyFormationChanged();
    });
  }

  String _cachedFormation = "4-2-3-1";
  String get _formationString => _cachedFormation;

  void _recomputeFormation() {
    const pitchW = 308.0;
    const pitchH = 224.0;
    final positions = List.generate(
      11,
      (i) => _customPositions[i] ?? _defaultPositions[i](pitchW, pitchH),
    );
    _cachedFormation = FormationAnalyzer.detect(positions, pitchW);
  }

  // Small UI chip used in the board controls – renamed to lowerCamelCase
  Widget _readoutChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.neonGlow.withValues(alpha: 0.18),
          width: 1.0,
        ),
        color: AppColors.frame.withValues(alpha: 0.35),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGlow.withValues(alpha: 0.06),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 2.2,
              color: AppColors.neonGlow.withValues(alpha: 0.65),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardContent(Size screenSize, {bool rotateNumbers = false}) {
    return _TiltCard(
      pulseAnim: _pulse,
      passAnim: _passAnim,
      selectedPlayer: _selectedPlayer,
      onPlayerTapped: _onPlayerTapped,
      dragModeEnabled: _dragMode,
      customPositions: _customPositions,
      onPlayerDragged: _onPlayerDragged,
      showHeatmap: _showHeatmap,
      formationString: _formationString,
      rotateNumbers: rotateNumbers,
      screenSize: screenSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final isMobileLandscape = isLandscape && screenSize.height < 500;

    if (isMobileLandscape) {
      return Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _formAnim,
                  builder: (_, child) => Transform.scale(
                    scale: 1.0 - _formAnim.value * 0.02,
                    child: child,
                  ),
                  child: _buildBoardContent(screenSize),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingLabel(
                    label: _dragMode ? 'DRAG MODE' : 'TAP TO SELECT',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _readoutChip(label: 'FMT', value: _formationString),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 0,
                    children: [
                      _iconBtn(
                        _dragMode ? Icons.edit_off : Icons.edit,
                        _dragMode ? AppColors.accent3 : AppColors.neonGlow,
                        _toggleDragMode,
                        'Edit Mode',
                      ),
                      _iconBtn(
                        _showHeatmap ? Icons.grid_on : Icons.grid_off,
                        _showHeatmap ? AppColors.gold : AppColors.secondaryGlow,
                        _toggleHeatmap,
                        'Heatmap',
                      ),
                      _iconBtn(
                        _expanded ? Icons.fullscreen_exit : Icons.fullscreen,
                        _expanded ? AppColors.gold : AppColors.neonGlow,
                        _toggleExpand,
                        _expanded ? 'Close fullscreen' : 'Expand',
                      ),
                      if (_dragMode) ...[
                        _iconBtn(
                          Icons.undo,
                          AppColors.neonGlow,
                          _historyIndex > 0 ? _undo : null,
                          'Undo',
                        ),
                        _iconBtn(
                          Icons.redo,
                          AppColors.neonGlow,
                          _historyIndex < _history.length - 1 ? _redo : null,
                          'Redo',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (_expanded)
            _FullscreenOverlay(
              isMobile: screenSize.shortestSide < 600,
              onClose: _toggleExpand,
              dragMode: _dragMode,
              onToggleEdit: _toggleDragMode,
              historyIndex: _historyIndex,
              historyLength: _history.length,
              onUndo: _historyIndex > 0 ? _undo : null,
              onRedo: _historyIndex < _history.length - 1 ? _redo : null,
              child: _buildBoardContent(
                screenSize,
                rotateNumbers: screenSize.shortestSide < 600,
              ),
            ),
        ],
      );
    }

    final boardColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ScoreTicker(),
        const SizedBox(height: 16),
        _PulsingLabel(
          label: _dragMode
              ? 'DRAG MODE  ·  MOVE PLAYERS  (GK LOCKED)'
              : 'DRAG  ·  TILT  ·  TAP  TO  SELECT',
        ),
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: Listenable.merge([_levitate, _formAnim]),
          builder: (_, child) => Transform.translate(
            offset: Offset(0, math.sin(_levitate.value * math.pi) * -8),
            child: Transform.scale(
              scale: 1.0 - _formAnim.value * 0.02,
              child: child,
            ),
          ),
          child: RepaintBoundary(child: _buildBoardContent(screenSize)),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_readoutChip(label: 'FORMATION', value: _formationString)],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _iconBtn(
              _dragMode ? Icons.edit_off : Icons.edit,
              _dragMode ? AppColors.accent3 : AppColors.neonGlow,
              _toggleDragMode,
              'Edit Mode',
            ),
            _iconBtn(
              _showHeatmap ? Icons.grid_on : Icons.grid_off,
              _showHeatmap ? AppColors.gold : AppColors.secondaryGlow,
              _toggleHeatmap,
              'Heatmap',
            ),
            _iconBtn(
              _expanded ? Icons.fullscreen_exit : Icons.fullscreen,
              _expanded ? AppColors.gold : AppColors.neonGlow,
              _toggleExpand,
              _expanded ? 'Close fullscreen' : 'Expand',
            ),
            if (_dragMode) ...[
              _iconBtn(
                Icons.undo,
                AppColors.neonGlow,
                _historyIndex > 0 ? _undo : null,
                'Undo',
              ),
              _iconBtn(
                Icons.redo,
                AppColors.neonGlow,
                _historyIndex < _history.length - 1 ? _redo : null,
                'Redo',
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
      ],
    );

    return Stack(
      children: [
        boardColumn,
        if (_expanded)
          _FullscreenOverlay(
            isMobile: screenSize.shortestSide < 600,
            onClose: _toggleExpand,
            dragMode: _dragMode,
            onToggleEdit: _toggleDragMode,
            historyIndex: _historyIndex,
            historyLength: _history.length,
            onUndo: _historyIndex > 0 ? _undo : null,
            onRedo: _historyIndex < _history.length - 1 ? _redo : null,
            child: _buildBoardContent(
              screenSize,
              rotateNumbers: screenSize.shortestSide < 600,
            ),
          ),
      ],
    );
  }

  Widget _iconBtn(
    IconData icon,
    Color color,
    VoidCallback? onPressed,
    String tooltip,
  ) => IconButton(
    icon: Icon(icon, color: color, size: 20),
    onPressed: onPressed,
    tooltip: tooltip,
  );
}

// ─── Fullscreen Overlay ──────────────────────────────────────────────────────
class _FullscreenOverlay extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;
  final bool isMobile;
  final bool dragMode;
  final VoidCallback onToggleEdit;
  final int historyIndex;
  final int historyLength;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  const _FullscreenOverlay({
    required this.child,
    required this.onClose,
    required this.isMobile,
    required this.dragMode,
    required this.onToggleEdit,
    required this.historyIndex,
    required this.historyLength,
    this.onUndo,
    this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final w = mq.width;
    final h = mq.height;

    Widget board = SizedBox(
      width: w - 32,
      height: h - 32,
      child: FittedBox(fit: BoxFit.contain, child: child),
    );

    final content = isMobile
        ? RotatedBox(quarterTurns: 3, child: board)
        : board;

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: AppColors.background.withValues(alpha: 0.96),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _OverlayGridPainter()),
                ),
              ),
              Center(child: content),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _OverlayIconBtn(
                          icon: dragMode ? Icons.edit_off : Icons.edit,
                          color: dragMode
                              ? AppColors.accent3
                              : AppColors.neonGlow,
                          onTap: onToggleEdit,
                          tooltip: dragMode ? 'Exit Edit Mode' : 'Edit Mode',
                          active: dragMode,
                        ),
                        if (dragMode) ...[
                          const SizedBox(width: 4),
                          _OverlayIconBtn(
                            icon: Icons.undo,
                            color: onUndo != null
                                ? AppColors.neonGlow
                                : AppColors.grid,
                            onTap: onUndo,
                            tooltip: 'Undo',
                          ),
                          const SizedBox(width: 4),
                          _OverlayIconBtn(
                            icon: Icons.redo,
                            color: onRedo != null
                                ? AppColors.neonGlow
                                : AppColors.grid,
                            onTap: onRedo,
                            tooltip: 'Redo',
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          dragMode
                              ? 'DRAG PLAYERS  ·  GK LOCKED'
                              : 'TAP  TO  SELECT',
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 2.5,
                            color: dragMode
                                ? AppColors.accent3.withValues(alpha: 0.7)
                                : AppColors.secondaryGlow.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                        ),
                        const Spacer(),
                        _ExitFullscreenBtn(onTap: onClose),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(child: _OverlayCornerBrackets()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String tooltip;
  final bool active;

  const _OverlayIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? AppColors.accent3.withValues(alpha: 0.15)
              : AppColors.frame.withValues(alpha: 0.60),
          border: Border.all(
            color: color.withValues(alpha: onTap != null ? 0.45 : 0.18),
            width: 1.2,
          ),
        ),
        child: Icon(
          icon,
          color: color.withValues(alpha: onTap != null ? 1.0 : 0.35),
          size: 18,
        ),
      ),
    ),
  );
}

class _OverlayGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grid.withValues(alpha: 0.06)
      ..strokeWidth = 0.5;
    const step = 64.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_OverlayGridPainter old) => false;
}

class _OverlayCornerBrackets extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      for (final a in [
        const Alignment(-1.0, -1.0),
        const Alignment(1.0, -1.0),
        const Alignment(-1.0, 1.0),
        const Alignment(1.0, 1.0),
      ])
        Align(
          alignment: a,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(
                painter: _BracketPainter(
                  a.x < 0,
                  a.y < 0,
                  AppColors.neonGlow.withValues(alpha: 0.35),
                  1.8,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class _ExitFullscreenBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _ExitFullscreenBtn({required this.onTap});

  @override
  State<_ExitFullscreenBtn> createState() => _ExitFullscreenBtnState();
}

class _ExitFullscreenBtnState extends State<_ExitFullscreenBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _t = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _ctrl.forward(),
    onTapUp: (_) {
      _ctrl.reverse();
      widget.onTap();
    },
    onTapCancel: () => _ctrl.reverse(),
    child: MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _t,
        builder: (_, __) => Transform.scale(
          scale: 1.0 + _t.value * 0.12,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.frame.withValues(alpha: 0.72 + _t.value * 0.18),
              border: Border.all(
                color: AppColors.neonGlow.withValues(
                  alpha: 0.25 + _t.value * 0.55,
                ),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGlow.withValues(alpha: _t.value * 0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.close_rounded,
              color: AppColors.neonGlow.withValues(alpha: 0.7 + _t.value * 0.3),
              size: 20,
            ),
          ),
        ),
      ),
    ),
  );
}

// ─── Pulsing Label ──────────────────────────────────────────────────────────
class _PulsingLabel extends StatefulWidget {
  final String label;
  const _PulsingLabel({required this.label});

  @override
  State<_PulsingLabel> createState() => _PulsingLabelState();
}

class _PulsingLabelState extends State<_PulsingLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Text(
      widget.label,
      style: TextStyle(
        fontSize: 10,
        letterSpacing: 3.5,
        color: AppColors.secondaryGlow.withValues(
          alpha: 0.35 + _ctrl.value * 0.38,
        ),
      ),
    ),
  );
}

// ─── Tilt Card ──────────────────────────────────────────────────────────────
class _TiltCard extends StatelessWidget {
  final Animation<double> pulseAnim, passAnim;
  final int? selectedPlayer;
  final ValueChanged<int?> onPlayerTapped;
  final bool dragModeEnabled;
  final List<Offset?> customPositions;
  final void Function(int, Offset) onPlayerDragged;
  final bool showHeatmap;
  final String formationString;
  final bool rotateNumbers;
  final Size screenSize;

  const _TiltCard({
    required this.pulseAnim,
    required this.passAnim,
    required this.selectedPlayer,
    required this.onPlayerTapped,
    required this.dragModeEnabled,
    required this.customPositions,
    required this.onPlayerDragged,
    required this.showHeatmap,
    required this.formationString,
    this.rotateNumbers = false,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 336,
    height: 252,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: AppColors.frame.withValues(alpha: 0.88),
      border: Border.all(
        color: AppColors.neonGlow.withValues(alpha: 0.22),
        width: 1.3,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.neonGlow.withValues(alpha: 0.12),
          blurRadius: 40,
          spreadRadius: 3,
        ),
        BoxShadow(
          color: AppColors.teamB.withValues(alpha: 0.04),
          blurRadius: 60,
          spreadRadius: 8,
        ),
        BoxShadow(
          color: AppColors.hologram.withValues(alpha: 0.07),
          blurRadius: 80,
          spreadRadius: 16,
        ),
      ],
      gradient: LinearGradient(
        begin: const Alignment(0, 0),
        end: Alignment.bottomRight,
        colors: [
          AppColors.neonGlow.withValues(alpha: 0.10),
          AppColors.frame.withValues(alpha: 0.92),
          AppColors.grid.withValues(alpha: 0.28),
        ],
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          const _TopGradientLine(),
          ..._cornerBrackets(AppColors.neonGlow.withValues(alpha: 0.55)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: RepaintBoundary(
                child: PitchWidget(
                  pulseAnim: pulseAnim,
                  passAnim: passAnim,
                  selectedPlayer: selectedPlayer,
                  onPlayerTapped: onPlayerTapped,
                  dragModeEnabled: dragModeEnabled,
                  customPositions: customPositions,
                  onPlayerDragged: onPlayerDragged,
                  showHeatmap: showHeatmap,
                  rotateNumbers: rotateNumbers,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _HoloPainter(specularX: 0.5, specularY: 0.5),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 14,
            child: Text(
              formationString,
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 2.5,
                color: AppColors.neonGlow.withValues(alpha: 0.45),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 14,
            child: Text(
              'PASS LINES  ON',
              style: TextStyle(
                fontSize: 7,
                letterSpacing: 1.8,
                color: AppColors.hologram.withValues(alpha: 0.38),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 14,
            child: Text(
              '0° 0°',
              style: TextStyle(
                fontSize: 7,
                letterSpacing: 1.2,
                fontFamily: 'monospace',
                color: AppColors.secondaryGlow.withValues(alpha: 0.28),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Holo Painter (cached shaders) ─────────────────────────────────────────
class _HoloPainter extends CustomPainter {
  final double specularX, specularY;
  ui.Shader? _cachedShader1;
  ui.Shader? _cachedShader2;

  _HoloPainter({required this.specularX, required this.specularY});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    _cachedShader1 ??= RadialGradient(
      center: Alignment(specularX * 2 - 1, specularY * 2 - 1),
      radius: 1.2,
      colors: [
        HSVColor.fromAHSV(
          1.0,
          (specularX * 180 + specularY * 120) % 360,
          0.6,
          1.0,
        ).toColor().withValues(alpha: 0.06),
        Colors.transparent,
      ],
    ).createShader(rect);

    _cachedShader2 ??= RadialGradient(
      radius: 0.9,
      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.22)],
    ).createShader(rect);

    canvas.drawRect(rect, Paint()..shader = _cachedShader1);
    canvas.drawRect(rect, Paint()..shader = _cachedShader2);
  }

  @override
  bool shouldRepaint(_HoloPainter old) =>
      old.specularX != specularX || old.specularY != specularY;
}

// ─── Pitch Widget ────────────────────────────────────────────────────────────
class PitchWidget extends StatefulWidget {
  final Animation<double> pulseAnim, passAnim;
  final int? selectedPlayer;
  final ValueChanged<int?> onPlayerTapped;
  final bool dragModeEnabled;
  final List<Offset?> customPositions;
  final void Function(int, Offset) onPlayerDragged;
  final bool showHeatmap;
  final bool rotateNumbers;

  const PitchWidget({
    super.key,
    required this.pulseAnim,
    required this.passAnim,
    required this.selectedPlayer,
    required this.onPlayerTapped,
    required this.dragModeEnabled,
    required this.customPositions,
    required this.onPlayerDragged,
    required this.showHeatmap,
    this.rotateNumbers = false,
  });

  @override
  State<PitchWidget> createState() => _PitchWidgetState();
}

class _PitchWidgetState extends State<PitchWidget> {
  int? _draggingPlayer;
  int? _pendingTapHit;
  Offset? _downPos;

  List<Offset> _getPositions() => List.generate(
    11,
    (i) => widget.customPositions[i] ?? _defaultPositions[i](308.0, 224.0),
  );

  int? _hitTest(Offset localPosition) {
    const threshold = 34.0;
    final positions = _getPositions();
    double bestDist = threshold;
    int? hit;
    for (int i = 0; i < positions.length; i++) {
      final dist = (localPosition - positions[i]).distance;
      if (dist < bestDist) {
        bestDist = dist;
        hit = i;
      }
    }
    return hit;
  }

  void _handlePointerDown(PointerDownEvent e) {
    _downPos = e.localPosition;
    final hit = _hitTest(e.localPosition);
    if (hit == null) return;
    _pendingTapHit = hit;
    if (hit != 0) {
      setState(() => _draggingPlayer = hit);
    }
  }

  void _handlePointerMove(PointerMoveEvent e) {
    if (_draggingPlayer != null) {
      if (_downPos != null && (e.localPosition - _downPos!).distance > 8.0) {
        _pendingTapHit = null;
      }
      final newPos = Offset(
        e.localPosition.dx.clamp(8.0, 300.0),
        e.localPosition.dy.clamp(8.0, 216.0),
      );
      widget.onPlayerDragged(_draggingPlayer!, newPos);
    }
  }

  void _handlePointerUp(PointerUpEvent e) {
    if (_pendingTapHit != null) {
      widget.onPlayerTapped(_pendingTapHit);
      _pendingTapHit = null;
    }
    _downPos = null;
    setState(() => _draggingPlayer = null);
  }

  void _handlePointerCancel(PointerCancelEvent e) {
    _pendingTapHit = null;
    _downPos = null;
    setState(() => _draggingPlayer = null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dragModeEnabled) {
      return Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.pulseAnim, widget.passAnim]),
          builder: (_, __) => CustomPaint(
            size: const Size(308, 224),
            painter: _PitchPainter(
              pulse: widget.pulseAnim.value,
              passT: widget.passAnim.value,
              selectedPlayer: widget.selectedPlayer,
              customPositions: widget.customPositions,
              dragModeEnabled: widget.dragModeEnabled,
              draggingPlayer: _draggingPlayer,
              showHeatmap: widget.showHeatmap,
              rotateNumbers: widget.rotateNumbers,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTapDown: (d) {
        final hit = _hitTest(d.localPosition);
        widget.onPlayerTapped(hit);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.pulseAnim, widget.passAnim]),
        builder: (_, __) => CustomPaint(
          size: const Size(308, 224),
          painter: _PitchPainter(
            pulse: widget.pulseAnim.value,
            passT: widget.passAnim.value,
            selectedPlayer: widget.selectedPlayer,
            customPositions: widget.customPositions,
            dragModeEnabled: widget.dragModeEnabled,
            draggingPlayer: _draggingPlayer,
            showHeatmap: widget.showHeatmap,
            rotateNumbers: widget.rotateNumbers,
          ),
        ),
      ),
    );
  }
}

// ─── Pitch Painter ──────────────────────────────────────────────────────────
final _cachedJerseyPainters = <int, TextPainter>{};
TextPainter _jerseyPainter(int num) => _cachedJerseyPainters.putIfAbsent(
  num,
  () => _layoutText(
    '$num',
    const TextStyle(
      color: AppColors.background,
      fontSize: 8.5,
      fontWeight: FontWeight.w900,
    ),
  ),
);

final _cachedBandLabelPainters = <String, TextPainter>{};
TextPainter _bandLabelPainter(String text, Color color) =>
    _cachedBandLabelPainters.putIfAbsent(
      '$text-${color.toARGB32()}',
      () => _layoutText(
        text,
        TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );

class _PitchPainter extends CustomPainter {
  final double pulse, passT;
  final int? selectedPlayer;
  final List<Offset?> customPositions;
  final bool dragModeEnabled;
  final int? draggingPlayer;
  final bool showHeatmap;
  final bool rotateNumbers;

  _PitchPainter({
    required this.pulse,
    required this.passT,
    this.selectedPlayer,
    required this.customPositions,
    required this.dragModeEnabled,
    this.draggingPlayer,
    required this.showHeatmap,
    this.rotateNumbers = false,
  });

  Paint _lp(double alpha, {double width = 1.0, Color? color}) => Paint()
    ..color = (color ?? AppColors.neonGlow).withValues(alpha: alpha)
    ..strokeWidth = width
    ..style = PaintingStyle.stroke;

  ui.Picture? _cachedPitchPicture;
  Size? _cachedPitchSize;
  List<Offset>? _cachedPositions;
  List<Offset?>? _cachedCustomPositions;
  List<(Offset, Offset)>? _cachedEdges;
  List<Offset?>? _lastPositions;

  List<Offset> _getPositions(double w, double h) {
    if (_cachedCustomPositions != customPositions) {
      _cachedCustomPositions = customPositions;
      _cachedPositions = List.generate(
        11,
        (i) => customPositions[i] ?? _defaultPositions[i](w, h),
      );
    }
    return _cachedPositions!;
  }

  ui.Picture _buildPitchPicture(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final w = size.width;
    final h = size.height;

    for (int i = 0; i < 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * h / 8, w, h / 8),
        Paint()
          ..color =
              (i.isEven ? const Color(0xFF0A2218) : const Color(0xFF0D2A1F))
                  .withValues(alpha: 0.5),
      );
    }

    final r = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(8)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.neonGlow.withValues(alpha: 0.04),
            AppColors.background.withValues(alpha: 0.25),
          ],
        ).createShader(r),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(7)),
      _lp(0.55, width: 1.8),
    );

    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), _lp(0.25));
    canvas.drawCircle(Offset(w / 2, h / 2), 34, _lp(0.18, width: 1.2));
    canvas.drawCircle(Offset(w / 2, h / 2), 24, _lp(0.06));
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      3.0,
      Paint()
        ..color = AppColors.neonGlow.withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      2.0,
      Paint()..color = AppColors.neonGlow.withValues(alpha: 0.90),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.29, 56, h * 0.42),
      _lp(0.22, width: 1.1),
    );
    canvas.drawRect(
      Rect.fromLTWH(w - 56, h * 0.29, 56, h * 0.42),
      _lp(0.22, width: 1.1),
    );
    canvas.drawRect(Rect.fromLTWH(0, h * 0.37, 20, h * 0.26), _lp(0.15));
    canvas.drawRect(Rect.fromLTWH(w - 20, h * 0.37, 20, h * 0.26), _lp(0.15));

    canvas.drawRect(
      Rect.fromLTWH(-3, h * 0.40, 6, h * 0.20),
      _lp(0.70, width: 1.8),
    );
    canvas.drawRect(
      Rect.fromLTWH(w - 3, h * 0.40, 6, h * 0.20),
      _lp(0.70, width: 1.8),
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(46, h / 2), radius: 26),
      -math.pi / 2.5,
      math.pi / 1.25,
      false,
      _lp(0.20),
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w - 46, h / 2), radius: 26),
      math.pi - math.pi / 2.5,
      math.pi / 1.25,
      false,
      _lp(0.20),
    );

    for (final dx in [46.0, w - 46.0]) {
      canvas.drawCircle(
        Offset(dx, h / 2),
        2.0,
        Paint()..color = AppColors.neonGlow.withValues(alpha: 0.45),
      );
    }

    for (final c in [Offset.zero, Offset(w, 0), Offset(0, h), Offset(w, h)]) {
      final startA =
          (c.dx > 0 ? math.pi : 0) + (c.dy > 0 ? math.pi / 2 : -math.pi / 2);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: 8),
        startA,
        math.pi / 2,
        false,
        _lp(0.20),
      );
    }

    return recorder.endRecording();
  }

  @override
  void paint(Canvas canvas, Size sz) {
    final w = sz.width;
    final h = sz.height;

    if (_cachedPitchPicture == null || _cachedPitchSize != sz) {
      _cachedPitchPicture = _buildPitchPicture(sz);
      _cachedPitchSize = sz;
    }
    canvas.drawPicture(_cachedPitchPicture!);

    final posA = _getPositions(w, h);
    _drawAnimatedPassLines(canvas, posA, AppColors.teamA, passT, 0.0);
    _drawMovingBall(canvas, posA, passT);
    if (dragModeEnabled) _drawLayerLines(canvas, sz, posA);
    if (showHeatmap) _drawHeatmap(canvas, posA);

    for (int i = 0; i < posA.length; i++) {
      final isGK = i == 0;
      _drawPlayer(
        canvas,
        posA[i],
        isGK ? 10.0 : (i % 3 == 0 ? 9.0 + pulse * 1.2 : 9.0),
        isGK ? AppColors.gold : AppColors.teamA,
        pulse,
        _jerseyNumbers[i],
        selected: selectedPlayer == i,
        isDragging: dragModeEnabled && draggingPlayer == i,
        dragMode: dragModeEnabled,
        isGK: isGK,
        rotateNumber: rotateNumbers,
      );
    }

    if (selectedPlayer != null && selectedPlayer! < posA.length) {
      _drawPositionLabel(canvas, posA[selectedPlayer!], selectedPlayer!, sz);
    }

    if (dragModeEnabled) {
      final tp = _layoutText(
        'EDIT MODE',
        TextStyle(
          color: AppColors.accent3.withValues(alpha: 0.35),
          fontSize: 8,
          letterSpacing: 3,
          fontFamily: 'monospace',
        ),
      );
      tp.paint(canvas, Offset((w - tp.width) / 2, h - 12));
    }
  }

  void _drawLayerLines(Canvas canvas, Size sz, List<Offset> positions) {
    final w = sz.width;
    final h = sz.height;
    final bands = FormationAnalyzer.getBandAveragesX(positions, w);
    if (bands.length < 3) return;

    final dashPaint = Paint()
      ..color = AppColors.neonGlow.withValues(alpha: 0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const dashW = 6.0;
    const gapW = 4.0;
    final labels = ['DEF', 'MID', 'ATK'];
    final colors = [AppColors.gold, AppColors.hologram, AppColors.teamA];

    for (int i = 0; i < bands.length; i++) {
      final x = bands[i];
      double y = 0;
      bool draw = true;
      while (y < h) {
        final endY = (y + (draw ? dashW : gapW)).clamp(0.0, h);
        if (draw) canvas.drawLine(Offset(x, y), Offset(x, endY), dashPaint);
        draw = !draw;
        y += dashW + gapW;
      }
      final labelTp = _bandLabelPainter(
        labels[i],
        colors[i].withValues(alpha: 0.5),
      );
      labelTp.paint(canvas, Offset(x - labelTp.width / 2, 2));
      labelTp.paint(canvas, Offset(x - labelTp.width / 2, h - 11));
    }

    if (positions.isNotEmpty) {
      final gkX = positions[0].dx;
      canvas.drawLine(
        Offset(gkX, 0),
        Offset(gkX, h),
        Paint()
          ..color = AppColors.gold.withValues(alpha: 0.2)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
      );
      final gkTp = _bandLabelPainter(
        'GK',
        AppColors.gold.withValues(alpha: 0.4),
      );
      gkTp.paint(canvas, Offset(gkX - gkTp.width / 2, 2));
      gkTp.paint(canvas, Offset(gkX - gkTp.width / 2, h - gkTp.height - 2));
    }
  }

  void _drawHeatmap(Canvas canvas, List<Offset> positions) {
    for (final pos in positions) {
      canvas.drawCircle(
        pos,
        38,
        Paint()..color = AppColors.neonGlow.withValues(alpha: 0.04),
      );
      canvas.drawCircle(
        pos,
        24,
        Paint()..color = AppColors.neonGlow.withValues(alpha: 0.07),
      );
      canvas.drawCircle(
        pos,
        12,
        Paint()..color = AppColors.neonGlow.withValues(alpha: 0.11),
      );
    }
  }

  void _drawPositionLabel(
    Canvas canvas,
    Offset pos,
    int index,
    Size canvasSize,
  ) {
    const cardW = 52.0;
    const cardH = 36.0;
    const slant = 8.0;
    const stemLen = 14.0;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    if (rotateNumbers) {
      canvas.rotate(math.pi / 2);
    }

    final bool flipBelow = rotateNumbers
        ? pos.dx < cardH + stemLen + 8
        : pos.dy < cardH + stemLen + 8;

    final bool flipLeft = rotateNumbers
        ? pos.dy > canvasSize.height - (cardW + 20)
        : pos.dx > canvasSize.width - (cardW + 20);

    final double stemDirY = flipBelow ? 1.0 : -1.0;
    final double cardBaseY = flipBelow ? stemLen : -stemLen - cardH;

    canvas.drawLine(
      Offset(0, stemDirY * 7),
      Offset(flipLeft ? -8 : 8, stemDirY * stemLen),
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.7)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    final double cardLeft = flipLeft ? -(cardW + slant + 8) : 8.0;
    final cardPath = Path()
      ..moveTo(cardLeft + slant * 0.6, cardBaseY)
      ..lineTo(cardLeft + cardW + slant * 0.6, cardBaseY)
      ..lineTo(cardLeft + cardW, cardBaseY + cardH)
      ..lineTo(cardLeft, cardBaseY + cardH)
      ..close();
    final cardRect = Rect.fromLTWH(cardLeft, cardBaseY, cardW + slant, cardH);
    canvas.drawPath(
      cardPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.95),
            AppColors.frame.withValues(alpha: 0.85),
          ],
        ).createShader(cardRect),
    );
    canvas.drawPath(
      cardPath,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.75)
        ..strokeWidth = 1.1
        ..style = PaintingStyle.stroke,
    );

    _paintText(
      canvas,
      '#${_jerseyNumbers[index]}',
      TextStyle(
        color: AppColors.gold.withValues(alpha: 0.55),
        fontSize: 8,
        fontWeight: FontWeight.w900,
        fontFamily: 'monospace',
      ),
      Offset(cardLeft + slant * 0.6 + 6, cardBaseY + 3),
    );
    _paintText(
      canvas,
      _positionLabels[index],
      const TextStyle(
        color: AppColors.gold,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
      Offset(cardLeft + slant * 0.6 + 14, cardBaseY + (cardH - 14) / 2 + 3),
    );

    canvas.restore();
  }

  void _drawMovingBall(Canvas canvas, List<Offset> positions, double t) {
    final edges = _cachedEdges;
    if (edges == null) return;
    if (edges.isEmpty) return;
    final edgeT = (t * edges.length) % edges.length;
    final localT = edgeT - edgeT.floor();
    final ballPos = Offset.lerp(
      edges[edgeT.floor() % edges.length].$1,
      edges[edgeT.floor() % edges.length].$2,
      localT,
    )!;
    canvas.drawCircle(
      ballPos,
      5.5,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      ballPos,
      3.5,
      Paint()..color = AppColors.gold.withValues(alpha: 0.90),
    );
    canvas.drawCircle(
      Offset(ballPos.dx - 0.8, ballPos.dy - 0.8),
      1.2,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  void _drawAnimatedPassLines(
    Canvas canvas,
    List<Offset> positions,
    Color color,
    double t,
    double phase,
  ) {
    if (_lastPositions != customPositions || _cachedEdges == null) {
      _lastPositions = customPositions;
      const maxDist = 100.0;
      _cachedEdges = [
        for (int i = 0; i < positions.length; i++)
          for (int j = i + 1; j < positions.length; j++)
            if ((positions[i] - positions[j]).distance < maxDist)
              (positions[i], positions[j]),
      ];
    }
    final edges = _cachedEdges!;
    if (edges.isEmpty) return;

    const dashLen = 4.0;
    const gapLen = 4.0;
    const period = dashLen + gapLen;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08 + pulse * 0.05)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final (a, b) in edges) {
      final d = (a - b).distance;
      final dir = (b - a) / d;
      final offset = ((t + phase) * period * 2) % period;
      double dist = -offset;
      while (dist < d) {
        final start = dist.clamp(0.0, d);
        final end = (dist + dashLen).clamp(0.0, d);
        if (end > start) {
          canvas.drawLine(a + dir * start, a + dir * end, paint);
        }
        dist += period;
      }
    }
  }

  void _drawPlayer(
    Canvas canvas,
    Offset pos,
    double r,
    Color color,
    double p,
    int num, {
    required bool selected,
    required bool isDragging,
    required bool dragMode,
    required bool isGK,
    bool rotateNumber = false,
  }) {
    final c = dragMode && !isGK ? AppColors.accent3 : color;
    final outerR =
        r +
        (selected
            ? 10
            : isDragging
            ? 12
            : 6);
    final midR =
        r +
        (selected
            ? 4
            : isDragging
            ? 5
            : 2.5);
    final outerA = selected
        ? 0.14
        : isDragging
        ? 0.22
        : 0.045 + p * 0.05;
    final midA = selected
        ? 0.28
        : isDragging
        ? 0.35
        : 0.13 + p * 0.09;

    canvas.drawCircle(
      pos,
      outerR,
      Paint()..color = c.withValues(alpha: outerA * 0.7),
    );
    canvas.drawCircle(pos, midR, Paint()..color = c.withValues(alpha: midA));
    canvas.drawCircle(pos, r, Paint()..color = c.withValues(alpha: 0.95));
    canvas.drawCircle(
      Offset(pos.dx - r * 0.2, pos.dy - r * 0.2),
      r * 0.35,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    if (selected) {
      canvas.drawCircle(
        pos,
        r + 6,
        Paint()
          ..color = c.withValues(alpha: 0.60)
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
        pos,
        r + 10,
        Paint()
          ..color = c.withValues(alpha: 0.22)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
      );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: r + 13),
        p * math.pi * 2,
        math.pi * 0.7,
        false,
        Paint()
          ..color = c.withValues(alpha: 0.35)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }

    if (dragMode && !isGK) {
      canvas.drawCircle(
        pos,
        r + 3,
        Paint()
          ..color = AppColors.accent3.withValues(alpha: isDragging ? 0.8 : 0.35)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke,
      );
    }

    final np = _jerseyPainter(num);

    if (rotateNumber) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(math.pi / 2);
      np.paint(canvas, Offset(-np.width / 2, -np.height / 2));
      canvas.restore();
    } else {
      np.paint(canvas, Offset(pos.dx - np.width / 2, pos.dy - np.height / 2));
    }
  }

  @override
  bool shouldRepaint(_PitchPainter old) =>
      old.pulse != pulse ||
      old.passT != passT ||
      old.selectedPlayer != selectedPlayer ||
      old.customPositions != customPositions ||
      old.dragModeEnabled != dragModeEnabled ||
      old.draggingPlayer != draggingPlayer ||
      old.showHeatmap != showHeatmap ||
      old.rotateNumbers != rotateNumbers;
}

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
        curve: Interval(start, end, curve: _morphCurve),
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
      _staggered(RepaintBoundary(child: const _LiveChip()), 0),
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
      _staggered(const _LegacyStatsCardStub(), 3),

      const SizedBox(height: 18),
      _staggered(const _MatchBarRow(), 4),
      const SizedBox(height: 18),
      _staggered(_TeamLegendRow(), 5),
      const SizedBox(height: 22),
      _staggered(const _TacticalNotesCard(), 6),
    ],
  );
}

class _LegacyStatsCardStub extends StatelessWidget {
  const _LegacyStatsCardStub();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.grid.withValues(alpha: 0.55)),
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.frame.withValues(alpha: 0.40),
          AppColors.grid.withValues(alpha: 0.12),
        ],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEGACY STATS',
          style: TextStyle(
            fontSize: 9,
            color: AppColors.hologram,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Formation intelligence cards are currently simplified for performance. '
          'Heatmap + layer lines are powered by custom painters on the board.',
          style: TextStyle(fontSize: 12, height: 1.65, color: Colors.white),
        ),
      ],
    ),
  );
}

class _TeamLegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.grid.withValues(alpha: 0.55)),
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.frame.withValues(alpha: 0.40),
          AppColors.grid.withValues(alpha: 0.12),
        ],
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _LegendItem(color: AppColors.gold, label: 'DEF'),
        _LegendItem(color: AppColors.hologram, label: 'MID'),
        _LegendItem(color: AppColors.teamA, label: 'ATTK'),
      ],
    ),
  );
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

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

class _TacticalNotesCard extends StatelessWidget {
  const _TacticalNotesCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.grid.withValues(alpha: 0.55)),
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.frame.withValues(alpha: 0.40),
          AppColors.grid.withValues(alpha: 0.12),
        ],
      ),
    ),
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
class _MatchBarRow extends StatefulWidget {
  const _MatchBarRow();
  @override
  State<_MatchBarRow> createState() => _MatchBarRowState();
}

class _MatchBarRowState extends State<_MatchBarRow>
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
    _curved = CurvedAnimation(parent: _ctrl, curve: _morphCurve);
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
                child: _DualBar(
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

class _DualBar extends StatelessWidget {
  final String label;
  final double aVal, bVal, rawA, rawB;
  const _DualBar({
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
class _LiveChip extends StatefulWidget {
  const _LiveChip();
  @override
  State<_LiveChip> createState() => _LiveChipState();
}

class _LiveChipState extends State<_LiveChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
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
