import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';
import '../data/profile_data.dart';
import '../widgets/morph_reveal.dart';
import 'section_shell.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _catLabel(ProjectCategory c) => switch (c) {
      ProjectCategory.flutter => 'FLUTTER',
      ProjectCategory.web => 'WEB',
      ProjectCategory.backend => 'BACKEND',
      ProjectCategory.desktop => 'DESKTOP',
      ProjectCategory.tooling => 'TOOLING',
      ProjectCategory.security => 'SECURITY',
    };

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── Section ───────────────────────────────────────────────────────────────────

class ProjectsSection extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;
  const ProjectsSection({super.key, required this.rawOffsetNotifier});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;
    return PortfolioSectionShell(
      rawOffsetNotifier: rawOffsetNotifier,
      label: '── FEATURED PROJECTS',
      triggerAt: 820,
      children: [
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 830,
          child: Text(
            'Tactical deployments — freelance, academic, and personal builds.',
            style: AppTypography.body(
                size: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.85)),
          ),
        ),
        const SizedBox(height: 28),
        _AlternatingGrid(
            projects: ProfileData.featuredProjects,
            notifier: rawOffsetNotifier,
            triggerBase: 850,
            isWide: isWide),
        const SizedBox(height: 44),
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 1100,
          child: Row(children: [
            _BlinkDot(color: AppColors.secondary),
            const SizedBox(width: 8),
            Text('ACADEMIC & CAPSTONE',
                style: AppTypography.hudLabel(color: AppColors.secondary)),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.secondary.withValues(alpha: 0.5),
                    AppColors.secondary.withValues(alpha: 0.0),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        _AlternatingGrid(
            projects: ProfileData.projects,
            notifier: rawOffsetNotifier,
            triggerBase: 1120,
            isWide: isWide),
      ],
    );
  }
}

// ── Blinking dot ──────────────────────────────────────────────────────────────

class _BlinkDot extends StatefulWidget {
  final Color color;
  const _BlinkDot({required this.color});
  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);
  late final Animation<double> _anim =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                  color: widget.color.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1)
            ],
          ),
        ),
      );
}

// ── Alternating grid ──────────────────────────────────────────────────────────

class _AlternatingGrid extends StatelessWidget {
  final List<ProjectEntry> projects;
  final ValueNotifier<double> notifier;
  final double triggerBase;
  final bool isWide;

  const _AlternatingGrid({
    required this.projects,
    required this.notifier,
    required this.triggerBase,
    required this.isWide,
  });

  Widget _reveal(int idx, ProjectEntry p, CrossAxisAlignment side) =>
      MorphReveal(
        offsetNotifier: notifier,
        triggerAt: triggerBase + idx * 40,
        delayMs: idx * 80,
        child: _ProjectCard(project: p, index: idx, accentSide: side),
      );

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: projects
            .asMap()
            .entries
            .map((e) => Padding(
                  padding: EdgeInsets.only(
                      bottom: e.key < projects.length - 1 ? 16 : 0),
                  child: _reveal(e.key, e.value, CrossAxisAlignment.start),
                ))
            .toList(),
      );
    }

    // On mobile web (narrow widths), force single-column.
    // The alternating 2-column Rows can still overflow due to intrinsic
    // sizing of the card content.
    if (Perf.isMobileWeb) {
      return Column(
        children: projects
            .asMap()
            .entries
            .map((e) => Padding(
                  padding: EdgeInsets.only(
                      bottom: e.key < projects.length - 1 ? 16 : 0),
                  child: _reveal(e.key, e.value, CrossAxisAlignment.start),
                ))
            .toList(),
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < projects.length; i += 2) {
      final flip = (i ~/ 2).isOdd;
      final hasSecond = i + 1 < projects.length;
      final isLast = i + 2 >= projects.length;
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: flip
              ? [
                  if (hasSecond) ...[
                    Expanded(
                        flex: 2,
                        child: _reveal(
                            i + 1, projects[i + 1], CrossAxisAlignment.end)),
                    const SizedBox(width: 16)
                  ],
                  Expanded(
                      flex: 3,
                      child: _reveal(i, projects[i], CrossAxisAlignment.start)),
                ]
              : [
                  Expanded(
                      flex: 3,
                      child: _reveal(i, projects[i], CrossAxisAlignment.end)),
                  if (hasSecond) ...[
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 2,
                        child: _reveal(
                            i + 1, projects[i + 1], CrossAxisAlignment.start))
                  ],
                ],
        ),
      ));
    }
    return Column(children: rows);
  }
}

// ── Project card ──────────────────────────────────────────────────────────────

class _ProjectCard extends StatefulWidget {
  final ProjectEntry project;
  final int index;
  final CrossAxisAlignment accentSide;
  const _ProjectCard(
      {required this.project, required this.index, required this.accentSide});
  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _tapActive = false;
  bool get _active => _hovered || _tapActive;

  late final AnimationController _scanCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
  late final Animation<double> _scanAnim =
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 120 + widget.index * 60), () {
      if (mounted) _scanCtrl.forward();
    });
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  // Shared animated badge — avoids the duplicated AnimatedContainer block
  Widget _catBadge(Color accent) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          border:
              Border.all(color: accent.withValues(alpha: _active ? 0.7 : 0.4)),
          color: accent.withValues(alpha: _active ? 0.14 : 0.08),
        ),
        child: Text(_catLabel(widget.project.category),
            style:
                AppTypography.mono(size: 7, color: accent, letterSpacing: 1.2)),
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final accent = p.accent;
    final stripeLeft = widget.accentSide == CrossAxisAlignment.start;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          if (Perf.isMobileWeb) {
            setState(() => _tapActive = true);
            Future.delayed(const Duration(milliseconds: 450), () {
              if (mounted) setState(() => _tapActive = false);
            });
          }
        },
        behavior: HitTestBehavior.opaque,
        child: ClipRect(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _active ? -3 : 0, 0),
            decoration: BoxDecoration(
              boxShadow: _active
                  ? [
                      BoxShadow(
                          color: accent.withValues(alpha: 0.22),
                          blurRadius: 24,
                          spreadRadius: 2)
                    ]
                  : const [],
            ),
            child: Stack(children: [
              // Base panel
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.55),
                  border: Border.all(
                      color: accent.withValues(alpha: _active ? 0.5 : 0.2)),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (stripeLeft)
                        _AccentStripe(
                            accent: accent,
                            index: widget.index,
                            label: _catLabel(p.category),
                            hovered: _active),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              // Prevent RenderFlex overflow on mobile web.
                              maxHeight:
                                  Perf.isMobileWeb ? 220 : double.infinity,
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header: badge + year
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 0,
                                    children: [
                                      if (!stripeLeft) _catBadge(accent),
                                      Text(
                                        p.year,
                                        style: AppTypography.mono(
                                          size: 9,
                                          color: accent.withValues(alpha: 0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (stripeLeft) _catBadge(accent),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(p.name.toUpperCase(),
                                      style: AppTypography.heading(
                                          size: 14,
                                          color: accent,
                                          letterSpacing: 1.0)),
                                  const SizedBox(height: 3),
                                  Text(p.subtitle,
                                      style: AppTypography.body(
                                          size: 11,
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.85))),
                                  const SizedBox(height: 8),

                                  // Stack chips
                                  Wrap(
                                    spacing: 5,
                                    runSpacing: 4,
                                    children: p.stack
                                        .split('·')
                                        .map((t) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: accent.withValues(
                                                    alpha: 0.06),
                                                border: Border.all(
                                                    color: accent.withValues(
                                                        alpha: 0.2)),
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                              child: Text(t.trim(),
                                                  style: AppTypography.mono(
                                                      size: 8,
                                                      color: AppColors.primary
                                                          .withValues(
                                                              alpha: 0.65),
                                                      letterSpacing: 0.3)),
                                            ))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 10),

                                  // Divider
                                  Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: stripeLeft
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        end: stripeLeft
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        colors: [
                                          accent.withValues(alpha: 0.5),
                                          accent.withValues(alpha: 0.0)
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Bullets
                                  ...p.bullets.map((b) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Text('▸',
                                                    style: AppTypography.mono(
                                                        size: 9,
                                                        color:
                                                            accent.withValues(
                                                                alpha: 0.7))),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                  child: Text(b,
                                                      style: AppTypography.body(
                                                          size: 11,
                                                          color: AppColors
                                                              .textPrimary
                                                              .withValues(
                                                                  alpha: 0.65),
                                                          height: 1.5))),
                                            ]),
                                      )),

                                  // Links
                                  if (p.githubUrl != null ||
                                      p.liveUrl != null) ...[
                                    const SizedBox(height: 10),
                                    Wrap(spacing: 8, children: [
                                      if (p.githubUrl != null)
                                        _LinkChip(
                                            label: '⟨/⟩  GITHUB',
                                            onTap: () => _openUrl(p.githubUrl!),
                                            color: accent),
                                      if (p.liveUrl != null)
                                        _LinkChip(
                                            label: '↗  LIVE',
                                            onTap: () => _openUrl(p.liveUrl!),
                                            color: AppColors.success),
                                    ]),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!stripeLeft)
                        _AccentStripe(
                            accent: accent,
                            index: widget.index,
                            label: _catLabel(p.category),
                            hovered: _active,
                            flip: true),
                    ],
                  ),
                ),
              ),

              // Corner brackets on hover
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _active ? 1.0 : 0.0,
                    child: CustomPaint(painter: _CornerPainter(accent)),
                  ),
                ),
              ),

              // Scan-line sweep
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _scanAnim,
                    builder: (_, __) => _scanAnim.value >= 1.0
                        ? const SizedBox.shrink()
                        : CustomPaint(
                            painter: _ScanPainter(_scanAnim.value, accent)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Accent stripe ─────────────────────────────────────────────────────────────

class _AccentStripe extends StatelessWidget {
  final Color accent;
  final int index;
  final String label;
  final bool hovered;
  final bool flip;

  const _AccentStripe({
    required this.accent,
    required this.index,
    required this.label,
    required this.hovered,
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    final indexStr = (index + 1).toString().padLeft(2, '0');
    final borderSide = BorderSide(
        color: accent.withValues(alpha: hovered ? 0.6 : 0.25), width: 2);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 36,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: hovered ? 0.14 : 0.07),
        border: Border(
          left: flip ? BorderSide.none : borderSide,
          right: flip ? borderSide : BorderSide.none,
        ),
      ),
      child: CustomPaint(
        painter: _StripePainter(accent: accent),
        child: Center(
          child: RotatedBox(
            quarterTurns: flip ? 1 : 3,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(indexStr,
                  style: AppTypography.mono(
                      size: 8, color: accent, letterSpacing: 1.5)),
              const SizedBox(width: 6),
              Text('·',
                  style: AppTypography.mono(
                      size: 8, color: accent.withValues(alpha: 0.4))),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTypography.mono(
                      size: 7,
                      color: accent.withValues(alpha: 0.55),
                      letterSpacing: 1.2)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _StripePainter extends CustomPainter {
  final Color accent;
  const _StripePainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (double d = -size.height; d < size.width + size.height; d += 8) {
      canvas.drawLine(
          Offset(d, 0), Offset(d + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.accent != accent;
}

class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const l = 14.0, pad = 6.0;
    final w = size.width, h = size.height;
    canvas
      ..drawPath(
          Path()
            ..moveTo(pad, pad + l)
            ..lineTo(pad, pad)
            ..lineTo(pad + l, pad),
          p)
      ..drawPath(
          Path()
            ..moveTo(w - pad - l, pad)
            ..lineTo(w - pad, pad)
            ..lineTo(w - pad, pad + l),
          p)
      ..drawPath(
          Path()
            ..moveTo(pad, h - pad - l)
            ..lineTo(pad, h - pad)
            ..lineTo(pad + l, h - pad),
          p)
      ..drawPath(
          Path()
            ..moveTo(w - pad - l, h - pad)
            ..lineTo(w - pad, h - pad)
            ..lineTo(w - pad, h - pad - l),
          p);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

class _ScanPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ScanPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    canvas
      ..drawRect(Rect.fromLTWH(0, 0, size.width, y),
          Paint()..color = color.withValues(alpha: 0.04 * (1 - progress)))
      ..drawRect(
          Rect.fromLTWH(0, y - 2, size.width, 4),
          Paint()
            ..shader = LinearGradient(colors: [
              color.withValues(alpha: 0.0),
              color.withValues(alpha: 0.55),
              color.withValues(alpha: 0.0),
            ]).createShader(Rect.fromLTWH(0, y - 2, size.width, 4)));
  }

  @override
  bool shouldRepaint(_ScanPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Link chip ─────────────────────────────────────────────────────────────────

class _LinkChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _LinkChip(
      {required this.label, required this.onTap, required this.color});
  @override
  State<_LinkChip> createState() => _LinkChipState();
}

class _LinkChipState extends State<_LinkChip> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      widget.color.withValues(alpha: _hovered ? 0.75 : 0.35)),
              borderRadius: BorderRadius.circular(4),
              color: widget.color.withValues(alpha: _hovered ? 0.12 : 0.0),
            ),
            child: Text(widget.label,
                style: AppTypography.mono(
                    size: 8,
                    color:
                        widget.color.withValues(alpha: _hovered ? 1.0 : 0.7))),
          ),
        ),
      );
}
