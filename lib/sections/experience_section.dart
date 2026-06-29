import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/profile_data.dart';
import '../widgets/glass_panel.dart';
import '../widgets/hover_card.dart';
import '../widgets/morph_reveal.dart';
import 'section_shell.dart';

// ── Event style data ──────────────────────────────────────────────────────────

class _EventStyle {
  final IconData icon;
  final Color color;
  final String label;
  const _EventStyle(
      {required this.icon, required this.color, required this.label});
}

const _kStyles = <MatchEventType, _EventStyle>{
  MatchEventType.deployment: _EventStyle(
      icon: Icons.rocket_launch_outlined,
      color: AppColors.primary,
      label: 'DEPLOY'),
  MatchEventType.support: _EventStyle(
      icon: Icons.headset_mic_outlined,
      color: AppColors.secondary,
      label: 'SUPPORT'),
  MatchEventType.hardware: _EventStyle(
      icon: Icons.memory_outlined, color: AppColors.warning, label: 'HARDWARE'),
  MatchEventType.freelance: _EventStyle(
      icon: Icons.code_outlined, color: AppColors.success, label: 'FREELANCE'),
};

// ── Section ───────────────────────────────────────────────────────────────────

class ExperienceSection extends StatelessWidget {
  final ValueNotifier<double> rawOffsetNotifier;
  const ExperienceSection({super.key, required this.rawOffsetNotifier});

  @override
  Widget build(BuildContext context) {
    final entries = ProfileData.experience;
    return PortfolioSectionShell(
      rawOffsetNotifier: rawOffsetNotifier,
      label: '── MATCH TIMELINE',
      triggerAt: 640,
      children: [
        MorphReveal(
          offsetNotifier: rawOffsetNotifier,
          triggerAt: 655,
          child: Text(
            'Career events plotted like match incidents — deployments, support, hardware, freelance.',
            style: AppTypography.body(
                size: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.85)),
          ),
        ),
        const SizedBox(height: 24),
        ...entries.asMap().entries.map((e) => MorphReveal(
              offsetNotifier: rawOffsetNotifier,
              triggerAt: 660 + e.key * 40,
              delayMs: e.key * 60,
              child: _TimelineNode(
                entry: e.value,
                index: e.key,
                isLast: e.key == entries.length - 1,
              ),
            )),
      ],
    );
  }
}

// ── Timeline node ─────────────────────────────────────────────────────────────

class _TimelineNode extends StatelessWidget {
  final ExperienceEntry entry;
  final int index;
  final bool isLast;

  const _TimelineNode(
      {required this.entry, required this.index, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final style = _kStyles[entry.eventType]!;
    final stripeLeft = index.isEven;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 2 : AppLayout.spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineMarker(style: style, isLast: isLast),
          const SizedBox(width: 12),
          Expanded(
            child: HoverCard(
              accent: style.color,
              child: GlassPanel(
                borderAlpha: 0.14,
                accentColor: style.color,
                padding: EdgeInsets.zero,
                // Stack instead of IntrinsicHeight+Row: IntrinsicHeight measures
                // intrinsic height by laying out children at an assumed width,
                // but _CardContent contains Expanded(child: Text(..., wrapping))
                // inside a Row (see _BulletRow) — Flex's intrinsic-height pass for
                // wrapped Flexible/Expanded text children doesn't always match the
                // final constrained layout width, so bullets can wrap to one extra
                // line at real layout time than predicted, causing a few px overflow.
                // A Stack lets the 32px-wide stripe just fill whatever height
                // _CardContent ends up needing, with no intrinsic measurement.
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: stripeLeft ? 32 : 0,
                        right: stripeLeft ? 0 : 32,
                      ),
                      child: _CardContent(entry: entry, style: style),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: stripeLeft ? 0 : null,
                      right: stripeLeft ? null : 0,
                      child: _AccentStripe(
                        accent: style.color,
                        index: index,
                        label: style.label,
                        flip: !stripeLeft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card content ──────────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  final ExperienceEntry entry;
  final _EventStyle style;

  const _CardContent({required this.entry, required this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppLayout.padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Badge(label: style.label, color: style.color),
              const Spacer(),
              Flexible(
                child: Text(
                  entry.period,
                  textAlign: TextAlign.right,
                  style: AppTypography.mono(
                      size: 9, color: AppColors.primary.withValues(alpha: 0.9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(entry.title.toUpperCase(),
              style: AppTypography.heading(size: 11, letterSpacing: 0.6)),
          const SizedBox(height: 6),
          Text(entry.company,
              style: AppTypography.title(
                  size: 12, color: AppColors.primary.withValues(alpha: 0.85))),
          if (entry.location.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(entry.location, style: AppTypography.caption(size: 11)),
          ],
          const SizedBox(height: 12),
          ...entry.bullets.map((b) => _BulletRow(text: b, color: style.color)),
        ],
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(label,
            style: AppTypography.mono(size: 7, color: color, letterSpacing: 1)),
      );
}

class _BulletRow extends StatelessWidget {
  final String text;
  final Color color;
  const _BulletRow({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('▸ ',
                style: TextStyle(
                    color: color.withValues(alpha: 0.8), fontSize: 11)),
            Expanded(
              child: Text(text,
                  style: AppTypography.body(
                      size: 12,
                      color: AppColors.textPrimary.withValues(alpha: 0.65),
                      height: 1.55)),
            ),
          ],
        ),
      );
}

// ── Timeline marker ───────────────────────────────────────────────────────────

class _TimelineMarker extends StatelessWidget {
  final _EventStyle style;
  final bool isLast;
  const _TimelineMarker({required this.style, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: style.color.withValues(alpha: 0.6), width: 2),
              color: style.color.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                    color: style.color.withValues(alpha: 0.25), blurRadius: 10)
              ],
            ),
            child: Icon(style.icon, size: 16, color: style.color),
          ),
          Container(
            width: 2,
            height: isLast ? 16 : 24,
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isLast
                    ? [
                        style.color.withValues(alpha: 0.35),
                        style.color.withValues(alpha: 0.0)
                      ]
                    : [
                        style.color.withValues(alpha: 0.5),
                        AppColors.grid.withValues(alpha: 0.25)
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Accent stripe ─────────────────────────────────────────────────────────────

class _AccentStripe extends StatelessWidget {
  final Color accent;
  final int index;
  final String label;
  final bool flip;

  const _AccentStripe(
      {required this.accent,
      required this.index,
      required this.label,
      this.flip = false});

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: accent.withValues(alpha: 0.28), width: 2);
    return Container(
      width: 32,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        border: Border(
          left: flip ? BorderSide.none : side,
          right: flip ? side : BorderSide.none,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _StripePainter(
                accent: accent,
                index: index,
                label: label,
                flip: flip,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: flip ? null : 0,
            right: flip ? 0 : null,
            child: IgnorePointer(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  border: Border.all(
                      color: accent.withValues(alpha: 0.35), width: 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(flip ? 6 : 0),
                    bottomRight: Radius.circular(flip ? 0 : 6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stripe painter ────────────────────────────────────────────────────────────

class _StripePainter extends CustomPainter {
  final Color accent;
  final int index;
  final String label;
  final bool flip;

  const _StripePainter({
    required this.accent,
    required this.index,
    required this.label,
    required this.flip,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // diagonal slash lines
    final linePaint = Paint()
      ..color = accent.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (double d = -size.height; d < size.width + size.height; d += 8.0) {
      canvas.drawLine(
          Offset(d, 0), Offset(d + size.height, size.height), linePaint);
    }

    // rotated text: index · label
    final indexStr = (index + 1).toString().padLeft(2, '0');

    void drawText(String text, double fontSize, Color color, double offset) {
      final tp = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                fontSize: fontSize, color: color, letterSpacing: 1.2)),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      // rotate around center, direction depends on flip
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(flip ? (3.14159 / 2) : -(3.14159 / 2));
      canvas.translate(-tp.width / 2, offset);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // measure total block height to center it
    const gap = 3.0;
    const idxSize = 7.0, dotSize = 7.0, lblSize = 6.0;
    final totalH = idxSize + gap + dotSize + gap + lblSize;
    final startY = -totalH / 2;

    drawText(indexStr, idxSize, accent, startY);
    drawText(
        '·', dotSize, accent.withValues(alpha: 0.4), startY + idxSize + gap);
    drawText(label, lblSize, accent.withValues(alpha: 0.55),
        startY + idxSize + gap + dotSize + gap);
  }

  @override
  bool shouldRepaint(_StripePainter old) =>
      old.accent != accent ||
      old.index != index ||
      old.label != label ||
      old.flip != flip;
}
