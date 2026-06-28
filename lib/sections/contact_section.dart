// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../data/profile_data.dart';
import '../widgets/glass_panel.dart';
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
    final isWide = MediaQuery.sizeOf(context).width > AppBalance.wideBreakpoint;
    final links = ProfileData.contactLinks;

    return PortfolioSectionShell(
      rawOffsetNotifier: rawOffsetNotifier,
      label: '── CONTACT',
      triggerAt: 980,
      children: [
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 1000,
          child: isWide
              ? IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 4, child: _OpenChannelPanel()),
                        SizedBox(width: AppLayout.spacing),
                        Expanded(
                            flex: 6,
                            child: _ContactGrid(
                                links: links,
                                notifier: rawOffsetNotifier,
                                openLink: _openLink)),
                      ]),
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _OpenChannelPanel(),
                  SizedBox(height: AppLayout.spacing),
                  _ContactGrid(
                      links: links,
                      notifier: rawOffsetNotifier,
                      openLink: _openLink),
                ]),
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
                letterSpacing: 1),
          ),
        ),
      ],
    );
  }
}

// ── Open Channel panel — HUD styled ──────────────────────────────────────────

class _OpenChannelPanel extends StatefulWidget {
  @override
  State<_OpenChannelPanel> createState() => _OpenChannelPanelState();
}

class _OpenChannelPanelState extends State<_OpenChannelPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GlassPanel(
        borderAlpha: 0.18,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status row
              Row(children: [
                FadeTransition(
                  opacity: _blink,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.7),
                            blurRadius: 6)
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('OPEN CHANNEL',
                    style: AppTypography.hudLabel(color: AppColors.secondary)),
                const Spacer(),
                Text('ONLINE',
                    style: AppTypography.mono(
                        size: 7,
                        color: AppColors.secondary.withValues(alpha: 0.55),
                        letterSpacing: 1.5)),
              ]),
              const SizedBox(height: 10),
              Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.secondary.withValues(alpha: 0.35),
                      AppColors.secondary.withValues(alpha: 0.0)
                    ]),
                  )),
              const SizedBox(height: 10),
              Text(
                'Reach out for IT support, systems, networking, or solutions engineering roles.',
                style: AppTypography.body(
                    size: 13,
                    color: AppColors.textPrimary.withValues(alpha: 0.65),
                    height: 1.55),
              ),
              const SizedBox(height: 12),
              // Availability tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3)),
                  color: AppColors.secondary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('▸  AVAILABLE FOR OPPORTUNITIES',
                    style: AppTypography.mono(
                        size: 7,
                        color: AppColors.secondary.withValues(alpha: 0.8),
                        letterSpacing: 1.2)),
              ),
            ]),
      );
}

// ── Contact grid — 2-column rows, resume chip highlighted ────────────────────

class _ContactGrid extends StatelessWidget {
  final List<ContactLink> links;
  final ValueNotifier<double> notifier;
  final Future<void> Function(String) openLink;

  const _ContactGrid(
      {required this.links, required this.notifier, required this.openLink});

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
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: _chip(i)),
            if (hasSecond) ...[
              SizedBox(width: AppLayout.spacing),
              Expanded(child: _chip(i + 1))
            ],
          ]),
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
