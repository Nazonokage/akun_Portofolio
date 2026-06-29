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

  // Cached so _scrollContent is never rebuilt unless keys change.
  late final Widget _scrollBody;
  // Cached inset+mobile flag — only changes on orientation, handled by build.
  bool _isMobile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _auroraCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 12));
    if (Perf.enableAuroraAnim) {
      _auroraCtrl.repeat(reverse: true);
    } else {
      _auroraCtrl.value = 0.5;
    }

    final isMobile = Perf.isMobileWeb;
    _entryCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: isMobile ? 500 : 1400),
    );
    _entryCurved = CurvedAnimation(parent: _entryCtrl, curve: morphCurve);
    Future.delayed(Duration(milliseconds: isMobile ? 0 : 120), () {
      if (mounted) _entryCtrl.forward();
    });

    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());

    // Build the scroll body once — all sections receive stable notifiers.
    _scrollBody = _buildScrollContent();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final offset = _scroll.offset;
    final hero = AppBalance.heroMorphProgress(offset);
    if ((_heroMorph.value - hero).abs() > 0.001) _heroMorph.value = hero;

    final published = Perf.lightEffects ? (offset / 8).round() * 8.0 : offset;
    if (published != _lastPublishedScroll) {
      _lastPublishedScroll = published;
      _rawOffset.value = published;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final paused = state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive;
    if (animationsPaused.value != paused) animationsPaused.value = paused;
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

  Widget _buildScrollContent() => BalancedContent(
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
            ProjectsSection(key: _projectsKey, rawOffsetNotifier: _rawOffset),
            contact.ContactSection(
                key: _contactKey, rawOffsetNotifier: _rawOffset),
            // Bottom breathing room — uses a fixed fraction; Builder avoids
            // a full-screen context dependency inside the cached subtree.
            Builder(
                builder: (ctx) =>
                    SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.15)),
          ],
        ),
      );

  // Background layer: merge the two separate listeners into one AnimatedBuilder
  // so we only need a single rebuild per aurora frame / scroll tick instead of
  // the previous nested double-rebuild.
  Widget _buildBackground() => Positioned.fill(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_rawOffset, _auroraCtrl]),
            builder: (_, __) => CustomPaint(
              painter: CombinedBgPainter(
                scroll: _rawOffset.value,
                auroraT: _auroraCtrl.value,
              ),
            ),
          ),
        ),
      );

  // Entry flash: use a single AnimatedBuilder that self-disposes by replacing
  // with a const SizedBox once the animation is done — no more per-frame
  // Container allocations after t > 0.35.
  Widget _buildEntryFlash() => Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _entryCtrl,
            builder: (_, __) {
              final t = _entryCtrl.value;
              if (t > 0.35) return const SizedBox.shrink();
              final alpha = (1.0 - t / 0.35).clamp(0.0, 1.0) * 0.055;
              return ColoredBox(
                  color: AppColors.primary.withValues(alpha: alpha));
            },
          ),
        ),
      );

  Widget _buildScrollable() => SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _editModeNotifier,
          builder: (_, isEditing, child) => SingleChildScrollView(
            controller: _scroll,
            physics: isEditing
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
            child: child,
          ),
          // On mobile skip the entry animation entirely — saves an
          // AnimatedBuilder + Transform on every frame for the cheapest path.
          child: _isMobile
              ? _scrollBody
              : AnimatedBuilder(
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
                  child: _scrollBody,
                ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final inset = AppBalance.horizontalInset(size.width);
    _isMobile = size.shortestSide < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          const Positioned.fill(
            child:
                RepaintBoundary(child: IgnorePointer(child: SpaceParticles())),
          ),
          _buildEntryFlash(),
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
          _buildScrollable(),
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
