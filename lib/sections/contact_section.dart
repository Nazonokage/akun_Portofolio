// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';
import '../data/profile_data.dart';
import '../widgets/hover_card.dart';
import '../widgets/morph_reveal.dart';
import '../widgets/readouts.dart';
import 'section_shell.dart';

class ContactSection extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;

  const ContactSection({
    super.key,
    required this.rawOffsetNotifier,
  });

  Future<void> _openLink(String uri) async {
    if (uri.startsWith('assets/')) {
      html.AnchorElement(href: uri)
        ..setAttribute('download', uri.split('/').last)
        ..click();
      return;
    }
    final target = Uri.parse(uri);
    if (await canLaunchUrl(target)) {
      await launchUrl(target, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = ProfileData.contactLinks;

    return PortfolioSectionShell(
      rawOffsetNotifier: rawOffsetNotifier,
      label: '── CONTACT',
      triggerAt: 980,
      children: [
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 1000,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OpenChannelPanel(),
              SizedBox(height: AppLayout.spacing),
              _ContactGrid(
                links: links,
                notifier: rawOffsetNotifier,
                openLink: _openLink,
              ),
            ],
          ),
        ),
        SizedBox(height: AppLayout.spacing),
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 1100,
          delayMs: 100,
          child: Text(
            '© ${DateTime.now().year} ${ProfileData.fullName}',
            style: AppTypography.caption(
              size: 10,
              color: AppColors.textSecondary.withValues(alpha: 0.45),
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Open Channel — Valorant schema style (matches project cards) ────────────

class _OpenChannelPanel extends StatefulWidget {
  @override
  State<_OpenChannelPanel> createState() => _OpenChannelPanelState();
}

class _OpenChannelPanelState extends State<_OpenChannelPanel>
    with SingleTickerProviderStateMixin {
  static const _accent = AppColors.secondary;

  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  bool _hovered = false;
  bool _tapActive = false;

  bool get _active => _hovered || _tapActive;

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  void _tapFeedback() {
    if (!Perf.isMobileWeb) return;
    setState(() => _tapActive = true);
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _tapActive = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _tapFeedback,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _active ? -3 : 0, 0),
          decoration: BoxDecoration(
            boxShadow: _active
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.22),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.55),
                  border: Border.all(
                    color: _accent.withValues(alpha: _active ? 0.5 : 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChannelStripe(hovered: _active),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(children: [
                              FadeTransition(
                                opacity: _blink,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _accent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _accent.withValues(alpha: 0.7),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'OPEN CHANNEL',
                                style: AppTypography.hudLabel(color: _accent),
                              ),
                              const Spacer(),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _accent.withValues(
                                      alpha: _active ? 0.7 : 0.4,
                                    ),
                                  ),
                                  color: _accent.withValues(
                                    alpha: _active ? 0.14 : 0.08,
                                  ),
                                ),
                                child: Text(
                                  'ONLINE',
                                  style: AppTypography.mono(
                                    size: 7,
                                    color: _accent,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 10),
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _accent.withValues(alpha: 0.5),
                                    _accent.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Reach out for IT support, systems, networking, or solutions engineering roles.',
                              style: AppTypography.body(
                                size: 13,
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.65,
                                ),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _accent.withValues(alpha: 0.3),
                                ),
                                color: _accent.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                '▸  AVAILABLE FOR OPPORTUNITIES',
                                style: AppTypography.mono(
                                  size: 7,
                                  color: _accent.withValues(alpha: 0.8),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _active ? 1.0 : 0.0,
                    child: CustomPaint(
                      painter: CornerBracketPainter(_accent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelStripe extends StatelessWidget {
  final bool hovered;
  const _ChannelStripe({required this.hovered});

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.secondary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 36,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: hovered ? 0.14 : 0.07),
        border: Border(
          left: BorderSide(
            color: accent.withValues(alpha: hovered ? 0.6 : 0.25),
            width: 2,
          ),
        ),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '01',
                style: AppTypography.mono(
                  size: 8,
                  color: accent,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '·',
                style: AppTypography.mono(
                  size: 8,
                  color: accent.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'COMMS',
                style: AppTypography.mono(
                  size: 7,
                  color: accent.withValues(alpha: 0.55),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Contact grid — 2-column rows, resume chip highlighted ────────────────────

class _ContactGrid extends StatelessWidget {
  final List<ContactLink> links;
  final ValueNotifier<double> notifier;
  final Future<void> Function(String) openLink;

  const _ContactGrid({
    required this.links,
    required this.notifier,
    required this.openLink,
  });

  bool _isResume(ContactLink l) => l.label.toUpperCase() == 'RESUME';

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < links.length; i += 2) {
      final hasSecond = i + 1 < links.length;
      final isLast = i + 2 >= links.length;
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : AppLayout.spacing),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _chip(i)),
              if (hasSecond) ...[
                SizedBox(width: AppLayout.spacing),
                Expanded(child: _chip(i + 1)),
              ],
            ],
          ),
        ),
      ));
    }
    return Column(children: rows);
  }

  Widget _chip(int i) {
    final link = links[i];
    final resume = _isResume(link);
    return MorphReveal(
      offsetNotifier: notifier,
      triggerAt: 1020 + i * 30,
      delayMs: i * 50,
      child: ContactChip(
        label: link.label,
        value: link.value,
        onTap: () => openLink(link.uri),
        accent: resume ? AppColors.success : null,
        prefix: resume ? '↓' : null,
      ),
    );
  }
}
