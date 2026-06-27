import 'package:flutter/material.dart';

import '../core/perf.dart';
import '../core/app_theme.dart';
import '../core/text_layout.dart';
import '../sections/about_section.dart';
import '../sections/contact_section.dart';
import '../sections/experience_section.dart';
import '../sections/hero_section.dart';
import '../sections/projects_section.dart';
import '../sections/skills_section.dart';
import '../tactic_board/background.dart';
import '../widgets/jump_to_contact.dart';
import '../tactic_board/scroll_progress.dart';

// ─── Main Screen ──────────────────────────────────────────────────────────
class TacticBoardScreen extends StatefulWidget {
  const TacticBoardScreen({super.key});
  @override
  State<TacticBoardScreen> createState() => _TacticBoardScreenState();
}

class _TacticBoardScreenState extends State<TacticBoardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0);
  final ValueNotifier<double> _rawOffset = ValueNotifier<double>(0);
  final ValueNotifier<bool> _editModeNotifier = ValueNotifier<bool>(false);
  final GlobalKey _contactKey = GlobalKey();

  late final AnimationController _auroraCtrl, _entryCtrl;
  late final Animation<double> _entryCurved;
  double _lastPublishedScroll = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auroraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (Perf.enableAuroraAnim) {
      _auroraCtrl.repeat(reverse: true);
    } else {
      _auroraCtrl.value = 0.5;
    }
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _entryCurved = CurvedAnimation(parent: _entryCtrl, curve: morphCurve);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _entryCtrl.forward();
    });

    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scroll.offset;
    final p = (offset / 420).clamp(0.0, 1.0);
    _scrollProgress.value = p;

    final published = Perf.lightEffects
        ? (offset / 4).round() * 4.0
        : offset;
    if (published != _lastPublishedScroll) {
      _lastPublishedScroll = published;
      _rawOffset.value = published;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final paused =
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive;
    if (animationsPaused.value != paused) {
      animationsPaused.value = paused;
    }
    if (paused) {
      _auroraCtrl.stop();
    } else if (Perf.enableAuroraAnim && mounted) {
      _auroraCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _auroraCtrl.dispose();
    _entryCtrl.dispose();
    _editModeNotifier.dispose();
    _scrollProgress.dispose();
    _rawOffset.dispose();
    LRUTextCache.clear();
    super.dispose();
  }

  void _jumpToContact() {
    final context = _contactKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
      );
    }
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
                    painter: CombinedBgPainter(
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
              child: IgnorePointer(child: SpaceParticles()),
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
                      ScrollProgressBar(progress: progress),
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
                      offset: Offset(0, lerp(40, 0, t)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    HeroSection(
                      scrollProgressNotifier: _scrollProgress,
                      editModeNotifier: _editModeNotifier,
                    ),
                    AboutSection(rawOffsetNotifier: _rawOffset),
                    SkillsSection(rawOffsetNotifier: _rawOffset),
                    ExperienceSection(rawOffsetNotifier: _rawOffset),
                    ProjectsSection(rawOffsetNotifier: _rawOffset),
                    ContactSection(
                      rawOffsetNotifier: _rawOffset,
                      sectionKey: _contactKey,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  ],
                ),
              ),
            ),
          ),
          JumpToContactButton(onPressed: _jumpToContact),
          if (Perf.enableScanLine)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(child: ScanLine()),
            ),
        ],
      ),
    );
  }
}

