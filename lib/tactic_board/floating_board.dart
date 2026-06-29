import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';
import 'background.dart';
import 'formation.dart';
import 'pitch.dart';
import 'score_ticker.dart';

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
  late final AnimationController _levitate, _pulse, _passAnim;
  bool _dragMode = false, _showHeatmap = false, _expanded = false;
  int? _selectedPlayer;
  List<Offset?> _customPositions = List.filled(11, null);
  List<List<Offset?>> _history = [];
  int _historyIndex = -1;
  String _currentFormation = "4-2-3-1";
  String _cachedFormation = "4-2-3-1";
  Timer? _dragDebounce;
  int? _pendingDragIndex;
  Offset? _pendingDragPos;

  String get _formationString => _cachedFormation;

  @override
  void initState() {
    super.initState();
    _levitate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    if (Perf.enableLevitate) {
      _levitate.repeat(reverse: true);
    }
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _passAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 20000),
    );
    if (!Perf.isMobileWeb) {
      _passAnim.repeat();
    }
    animationsPaused.addListener(_syncAnimPause);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recomputeFormation();
      _notifyFormationChanged();
    });
  }

  void _syncAnimPause() {
    if (animationsPaused.value) {
      _levitate.stop();
      _pulse.stop();
      _passAnim.stop();
    } else if (mounted) {
      if (Perf.enableLevitate) {
        _levitate.repeat(reverse: true);
      }
      _pulse.repeat(reverse: true);
      _passAnim.repeat();
    }
  }

  @override
  void dispose() {
    _dragDebounce?.cancel();
    animationsPaused.removeListener(_syncAnimPause);
    _levitate.dispose();
    _pulse.dispose();
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
    _pendingDragIndex = index;
    _pendingDragPos = newPos;
    _dragDebounce?.cancel();
    _dragDebounce = Timer(const Duration(milliseconds: 16), () {
      if (!mounted || _pendingDragIndex == null || _pendingDragPos == null) {
        return;
      }
      setState(() {
        _customPositions[_pendingDragIndex!] = _pendingDragPos!;
        _notifyFormationChanged();
      });
    });
  }

  void _recomputeFormation() {
    const pitchW = 308.0;
    const pitchH = 224.0;
    final positions = List.generate(
      11,
      (i) => _customPositions[i] ?? defaultPositions[i](pitchW, pitchH),
    );
    _cachedFormation = FormationAnalyzer.detect(positions, pitchW);
  }

  Widget _buildBoardContent(Size screenSize, {bool rotateNumbers = false}) {
    return TiltCard(
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

  Widget _buildControls({required bool compact}) => BoardControls(
        compact: compact,
        pulsingLabel: _dragMode
            ? (compact
                ? 'DRAG MODE'
                : 'DRAG MODE  ·  MOVE PLAYERS  (GK LOCKED)')
            : (compact ? 'TAP TO SELECT' : 'DRAG  ·  TILT  ·  TAP  TO  SELECT'),
        formationLabel: compact ? 'FMT' : 'FORMATION',
        formationValue: _formationString,
        dragMode: _dragMode,
        showHeatmap: _showHeatmap,
        expanded: _expanded,
        onToggleDragMode: _toggleDragMode,
        onToggleHeatmap: _toggleHeatmap,
        onToggleExpand: _toggleExpand,
        onUndo: _historyIndex > 0 ? _undo : null,
        onRedo: _historyIndex < _history.length - 1 ? _redo : null,
      );

  Widget _buildFullscreenOverlay(Size screenSize) => FullscreenOverlay(
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
      );

  void _pauseAnimationsIfOffscreen(bool offscreen) {
    if (offscreen) {
      _levitate.stop();
      _pulse.stop();
      _passAnim.stop();
    } else {
      if (Perf.enableLevitate) {
        _levitate.repeat(reverse: true);
      }
      _pulse.repeat(reverse: true);
      _passAnim.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final isMobileLandscape = isLandscape && screenSize.height < 500;

    final board = VisibilityDetector(
      key: const Key('floating_tactic_board_visibility'),
      onVisibilityChanged: (info) {
        // On mobile browsers this component is heavy; pause when it leaves view.
        if (Perf.isMobileWeb) {
          final offscreen = info.visibleFraction <= 0.01;
          if (offscreen != animationsPaused.value) {
            animationsPaused.value = offscreen;
          }

          _pauseAnimationsIfOffscreen(offscreen);
        }
      },
      child: RepaintBoundary(child: _buildBoardContent(screenSize)),
    );

    if (isMobileLandscape) {
      return Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              board,
              const SizedBox(width: 12),
              _buildControls(compact: true),
            ],
          ),
          if (_expanded) _buildFullscreenOverlay(screenSize),
        ],
      );
    }

    final boardColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ScoreTicker(),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _levitate,
          builder: (_, child) => Transform.translate(
            offset: Offset(
              0,
              Perf.enableLevitate
                  ? math.sin(_levitate.value * math.pi) * -8
                  : 0,
            ),
            child: child,
          ),
          child: RepaintBoundary(child: _buildBoardContent(screenSize)),
        ),
        const SizedBox(height: 10),
        _buildControls(compact: false),
        const SizedBox(height: 16),
      ],
    );

    return RepaintBoundary(
      child: Stack(
        children: [
          boardColumn,
          if (_expanded) _buildFullscreenOverlay(screenSize),
        ],
      ),
    );
  }
}

// ─── Fullscreen Overlay ──────────────────────────────────────────────────────
class FullscreenOverlay extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;
  final bool isMobile;
  final bool dragMode;
  final VoidCallback onToggleEdit;
  final int historyIndex;
  final int historyLength;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  const FullscreenOverlay({
    super.key,
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

    final content =
        isMobile ? RotatedBox(quarterTurns: 3, child: board) : board;

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: AppColors.background.withValues(alpha: 0.96),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: OverlayGridPainter()),
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
                        OverlayIconBtn(
                          icon: dragMode ? Icons.edit_off : Icons.edit,
                          color:
                              dragMode ? AppColors.accent3 : AppColors.neonGlow,
                          onTap: onToggleEdit,
                          tooltip: dragMode ? 'Exit Edit Mode' : 'Edit Mode',
                          active: dragMode,
                        ),
                        if (dragMode) ...[
                          const SizedBox(width: 4),
                          OverlayIconBtn(
                            icon: Icons.undo,
                            color: onUndo != null
                                ? AppColors.neonGlow
                                : AppColors.grid,
                            onTap: onUndo,
                            tooltip: 'Undo',
                          ),
                          const SizedBox(width: 4),
                          OverlayIconBtn(
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
                        ExitFullscreenBtn(onTap: onClose),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(child: OverlayCornerBrackets()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OverlayIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String tooltip;
  final bool active;

  const OverlayIconBtn({
    super.key,
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

class OverlayGridPainter extends CustomPainter {
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
  bool shouldRepaint(OverlayGridPainter old) => false;
}

class OverlayCornerBrackets extends StatelessWidget {
  const OverlayCornerBrackets({super.key});

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
                    painter: BracketPainter(
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

class ExitFullscreenBtn extends StatefulWidget {
  final VoidCallback onTap;
  const ExitFullscreenBtn({super.key, required this.onTap});

  @override
  State<ExitFullscreenBtn> createState() => _ExitFullscreenBtnState();
}

class _ExitFullscreenBtnState extends State<ExitFullscreenBtn>
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
                  color:
                      AppColors.frame.withValues(alpha: 0.72 + _t.value * 0.18),
                  border: Border.all(
                    color: AppColors.neonGlow.withValues(
                      alpha: 0.25 + _t.value * 0.55,
                    ),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.neonGlow.withValues(alpha: _t.value * 0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.neonGlow
                      .withValues(alpha: 0.7 + _t.value * 0.3),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
}

// ─── Pulsing Label ──────────────────────────────────────────────────────────
class PulsingLabel extends StatefulWidget {
  final String label;
  const PulsingLabel({super.key, required this.label});

  @override
  State<PulsingLabel> createState() => _PulsingLabelState();
}

class _PulsingLabelState extends State<PulsingLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
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
class TiltCard extends StatelessWidget {
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

  const TiltCard({
    super.key,
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
          boxShadow: Perf.lightEffects
              ? [
                  BoxShadow(
                    color: AppColors.neonGlow.withValues(alpha: 0.10),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ]
              : [
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
              const TopGradientLine(),
              ...cornerBracketsCache,
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
                    painter: HoloPainter(specularX: 0.5, specularY: 0.5),
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
class HoloPainter extends CustomPainter {
  final double specularX, specularY;
  ui.Shader? _cachedShader1;
  ui.Shader? _cachedShader2;

  HoloPainter({required this.specularX, required this.specularY});

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
  bool shouldRepaint(HoloPainter old) =>
      old.specularX != specularX || old.specularY != specularY;
}
