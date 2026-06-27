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
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.hologram,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reach out for IT support, systems, networking, or solutions engineering roles.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ProfileData.contactLinks.asMap().entries.map(
              (e) {
                final link = e.value;
                return MorphReveal(
                  offsetNotifier: rawOffsetNotifier,
                  triggerAt: 1020 + e.key * 30,
                  delayMs: e.key * 50,
                  child: ContactChip(
                    label: link.label,
                    value: link.value,
                    onTap: () => _openLink(link.uri),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 24),
          MorphReveal(
            offsetNotifier: rawOffsetNotifier,
            triggerAt: 1100,
            delayMs: 100,
            child: Text(
              '© ${DateTime.now().year} ${ProfileData.fullName}',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.secondaryGlow.withValues(alpha: 0.45),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
