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
  final GlobalKey sectionKey;

  const ContactSection({
    super.key,
    required this.rawOffsetNotifier,
    required this.sectionKey,
  });

  Future<void> _openLink(String uri) async {
    final target = Uri.parse(uri);
    if (await canLaunchUrl(target)) {
      await launchUrl(target, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > AppBalance.wideBreakpoint;
    final links = ProfileData.contactLinks;

    return KeyedSubtree(
      key: sectionKey,
      child: PortfolioSectionShell(
        rawOffsetNotifier: rawOffsetNotifier,
        label: '── CONTACT',
        triggerAt: 980,
        children: [
          MorphReveal(
            offsetNotifier: rawOffsetNotifier,
            triggerAt: 1000,
            child: GlassPanel(
              borderAlpha: 0.14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OPEN CHANNEL',
                    style: AppTypography.hudLabel(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reach out for IT support, systems, networking, or solutions engineering roles.',
                    style: AppTypography.body(
                      size: 13,
                      color: AppColors.textPrimary.withValues(alpha: 0.65),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppLayout.spacing),
          if (isWide)
            Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) SizedBox(width: AppLayout.spacing),
                        Expanded(
                          child: _ContactReveal(
                            rawOffsetNotifier: rawOffsetNotifier,
                            index: i,
                            link: links[i],
                            onTap: () => _openLink(links[i].uri),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppLayout.spacing),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _ContactReveal(
                          rawOffsetNotifier: rawOffsetNotifier,
                          index: 3,
                          link: links[3],
                          onTap: () => _openLink(links[3].uri),
                        ),
                      ),
                      SizedBox(width: AppLayout.spacing),
                      Expanded(
                        child: _ContactReveal(
                          rawOffsetNotifier: rawOffsetNotifier,
                          index: 4,
                          link: links[4],
                          onTap: () => _openLink(links[4].uri),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: links.asMap().entries.map((e) {
                return MorphReveal(
                  offsetNotifier: rawOffsetNotifier,
                  triggerAt: 1020 + e.key * 30,
                  delayMs: e.key * 50,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width > 360 ? 160 : double.infinity,
                    child: ContactChip(
                      label: e.value.label,
                      value: e.value.value,
                      onTap: () => _openLink(e.value.uri),
                    ),
                  ),
                );
              }).toList(),
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
      ),
    );
  }
}

class _ContactReveal extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;
  final int index;
  final ContactLink link;
  final VoidCallback onTap;

  const _ContactReveal({
    required this.rawOffsetNotifier,
    required this.index,
    required this.link,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MorphReveal(
      offsetNotifier: rawOffsetNotifier,
      triggerAt: 1020 + index * 30,
      delayMs: index * 50,
      child: ContactChip(
        label: link.label,
        value: link.value,
        onTap: onTap,
      ),
    );
  }
}
