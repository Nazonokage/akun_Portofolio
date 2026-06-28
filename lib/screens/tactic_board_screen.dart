import 'package:flutter/material.dart';

import '../core/perf.dart';
import '../core/app_theme.dart';
import '../core/text_layout.dart';
import '../sections/about_section.dart';
import '../sections/contact_section.dart' as contact;
import '../sections/experience_section.dart';
import '../sections/hero_section.dart';

import '../sections/projects_section.dart';
import '../sections/skills_section.dart';

import '../tactic_board/background.dart';
import '../widgets/balanced_content.dart';
import '../widgets/jump_to_contact.dart';
import '../tactic_board/scroll_progress.dart';

class TacticBoardScreen extends StatefulWidget {
  const TacticBoardScreen({super.key});
  @override
  State<TacticBoardScreen> createState() => _TacticBoardScreenState();
}

class _TacticBoardScreenState extends State<TacticBoardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _heroMorph = ValueNotifier<double>(0);
  final ValueNotifier<double> _rawOffset = ValueNotifier<double>(0);
  final ValueNotifier<bool> _editModeNotifier = ValueNotifier<bool>(false);
  final GlobalKey _contactKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();

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
      if (!mounted) return;
      if (MediaQuery.of(context).size.shortestSide >= 600) {
        _entryCtrl.forward();
      }
    });

    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;

    final offset = _scroll.offset;
    final hero = AppBalance.heroMorphProgress(offset);
    if ((_heroMorph.value - hero).abs() > 0.001) {
      _heroMorph.value = hero;
    }

    final published = Perf.lightEffects ? (offset / 4).round() * 4.0 : offset;
    if (published != _lastPublishedScroll) {
      _lastPublishedScroll = published;
      _rawOffset.value = published;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final paused = state == AppLifecycleState.paused ||
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
    _heroMorph.dispose();
    _rawOffset.dispose();
    LRUTextCache.clear();
    super.dispose();
  }

  void _jumpToContact() => _jumpToSection(_contactKey);
  void _jumpToProjects() => _jumpToSection(_projectsKey);

  void _jumpToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = AppBalance.horizontalInset(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
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
                    color: AppColors.primary.withValues(alpha: alpha),
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
                padding: EdgeInsets.fromLTRB(inset, 8, inset, 0),
                child: ScrollProgressBar(controller: _scroll),
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
                  final isMobile =
                      MediaQuery.of(context).size.shortestSide < 600;
                  if (isMobile) {
                    return child!;
                  }
                  return FadeTransition(
                    opacity: AlwaysStoppedAnimation(t.clamp(0.0, 1.0)),
                    child: Transform.translate(
                      offset: Offset(0, lerp(40, 0, t)),
                      child: child,
                    ),
                  );
                },
                child: BalancedContent(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      HeroSection(
                        scrollProgressNotifier: _heroMorph,
                        editModeNotifier: _editModeNotifier,
                        onViewProjects: _jumpToProjects,
                      ),
                      AboutSection(rawOffsetNotifier: _rawOffset),
                      SkillsSection(rawOffsetNotifier: _rawOffset),
                      ExperienceSection(rawOffsetNotifier: _rawOffset),
                      ProjectsSection(
                        key: _projectsKey,
                        rawOffsetNotifier: _rawOffset,
                      ),
                      contact.ContactSection(
                        key: _contactKey,
                        rawOffsetNotifier: _rawOffset,
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.15,
                      ),
                    ],
                  ),
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
