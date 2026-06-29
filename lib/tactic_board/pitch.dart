import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';
import '../core/text_layout.dart';
import 'formation.dart';

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
        (i) => widget.customPositions[i] ?? defaultPositions[i](308.0, 224.0),
      );

  int? _hitTest(Offset localPosition) {
    const threshold = 45.0;

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
    final painted = widget.dragModeEnabled
        ? Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            onPointerCancel: _handlePointerCancel,
            child: AnimatedBuilder(
              animation: Listenable.merge([widget.pulseAnim, widget.passAnim]),
              builder: (_, __) => CustomPaint(
                size: const Size(308, 224),
                painter: PitchPainter(
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
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              final hit = _hitTest(d.localPosition);
              widget.onPlayerTapped(hit);
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([widget.pulseAnim, widget.passAnim]),
              builder: (_, __) => CustomPaint(
                size: const Size(308, 224),
                painter: PitchPainter(
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

    return RepaintBoundary(child: painted);
  }
}

// ─── Pitch Painter ──────────────────────────────────────────────────────────
final _cachedJerseyPainters = <int, TextPainter>{};
TextPainter _jerseyPainter(int num) => _cachedJerseyPainters.putIfAbsent(
      num,
      () => layoutText(
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
      () => layoutText(
        text,
        TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );

class PitchPainter extends CustomPainter {
  final double pulse, passT;
  final int? selectedPlayer;
  final List<Offset?> customPositions;
  final bool dragModeEnabled;
  final int? draggingPlayer;
  final bool showHeatmap;
  final bool rotateNumbers;

  PitchPainter({
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
        (i) => customPositions[i] ?? defaultPositions[i](w, h),
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
    if (Perf.useBlur) {
      canvas.drawCircle(
        Offset(w / 2, h / 2),
        3.0,
        Paint()
          ..color = AppColors.neonGlow.withValues(alpha: 0.65)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    } else {
      canvas.drawCircle(
        Offset(w / 2, h / 2),
        4.5,
        Paint()..color = AppColors.neonGlow.withValues(alpha: 0.22),
      );
    }
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
        jerseyNumbers[i],
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
      final tp = layoutText(
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

    paintText(
      canvas,
      '#${jerseyNumbers[index]}',
      TextStyle(
        color: AppColors.gold.withValues(alpha: 0.55),
        fontSize: 8,
        fontWeight: FontWeight.w900,
        fontFamily: 'monospace',
      ),
      Offset(cardLeft + slant * 0.6 + 6, cardBaseY + 3),
    );
    paintText(
      canvas,
      positionLabels[index],
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
        ..color = AppColors.gold.withValues(alpha: Perf.useBlur ? 0.18 : 0.28)
        ..maskFilter =
            Perf.useBlur ? const MaskFilter.blur(BlurStyle.normal, 5) : null,
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
    final outerR = r +
        (selected
            ? 10
            : isDragging
                ? 12
                : 6);
    final midR = r +
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
  bool shouldRepaint(PitchPainter old) =>
      old.pulse != pulse ||
      old.passT != passT ||
      old.selectedPlayer != selectedPlayer ||
      old.customPositions != customPositions ||
      old.dragModeEnabled != dragModeEnabled ||
      old.draggingPlayer != draggingPlayer ||
      old.showHeatmap != showHeatmap ||
      old.rotateNumbers != rotateNumbers;
}
