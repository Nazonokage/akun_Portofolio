import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Football Tactical HUD palette (from design.json) ───────────────────────
class AppColors {
  // Backgrounds
  static const background = Color(0xFF081221);
  static const backgroundSecondary = Color(0xFF0B1E34);
  static const surface = Color(0xFF10263F);
  static const surfaceVariant = Color(0xFF17314A);
  static const grid = Color(0xFF1B3952);

  // Semantic colors
  static const primary = Color(0xFF3DF7F2);
  static const secondary = Color(0xFF22D7FF);
  static const accent = Color(0xFFA8FFFF);
  static const success = Color(0xFF59FF9A);
  static const warning = Color(0xFFFFD54A);
  static const danger = Color(0xFFFF5D73);
  static const textPrimary = Color(0xFFE6FFFF);
  static const textSecondary = Color(0xFF8FB7C7);
  static const disabled = Color(0xFF496272);

  // Legacy aliases (keep existing widgets compiling)
  static const frame = surface;
  static const neonGlow = primary;
  static const hologram = secondary;
  static const secondaryGlow = textSecondary;
  static const teamA = primary;
  static const teamB = danger;
  static const accent2 = Color(0xFF6C63FF);
  static const accent3 = warning;
  static const gold = warning;
}

// ─── Layout tokens (design.json) ───────────────────────────────────────────
class AppLayout {
  static const padding = 20.0;
  static const spacing = 18.0;
  static const cornerRadius = 18.0;
  static const borderWidth = 2.0;
  static const gridSpacing = 18.0;
  static const gridOpacity = 0.25;
}

// ─── Visual balance (symmetric rhythm + content cap) ───────────────────────
class AppBalance {
  static const maxContentWidth = 1120.0;
  static const heroMorphRange = 480.0;
  static const unit = 8.0;

  static const compactBreakpoint = 500.0;
  static const wideBreakpoint = 700.0;
  static const ultrawideBreakpoint = 900.0;

  /// Horizontal inset scales with viewport — keeps margins visually equal.
  static double horizontalInset(double width) {
    if (width >= ultrawideBreakpoint) return 32;
    if (width >= wideBreakpoint) return 24;
    if (width >= compactBreakpoint) return 20;
    return 16;
  }

  static EdgeInsets sectionPadding(double width) {
    final h = horizontalInset(width);
    final v = width < compactBreakpoint ? 32.0 : 44.0;
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  /// True scroll depth: 0 at top, 1 at bottom of scrollable content.
  static double scrollDepth(double pixels, double maxScrollExtent) {
    if (maxScrollExtent <= 0) return 0;
    return (pixels / maxScrollExtent).clamp(0.0, 1.0);
  }

  /// Hero board morph progress — independent of page length.
  static double heroMorphProgress(double pixels) =>
      (pixels / heroMorphRange).clamp(0.0, 1.0);
}

// ─── Effect tokens ───────────────────────────────────────────────────────────
class AppEffects {
  static const glowBlur = 16.0;
  static const glowSpread = 1.2;
  static const glowOpacity = 0.35;
}

// ─── Typography (Orbitron + Rajdhani) ────────────────────────────────────────
class AppTypography {
  static TextStyle heading({
    double size = 22,
    Color? color,
    double letterSpacing = 1.5,
  }) =>
      GoogleFonts.orbitron(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacing,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle title({
    double size = 18,
    Color? color,
  }) =>
      GoogleFonts.rajdhani(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body({
    double size = 14,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.rajdhani(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textPrimary.withValues(alpha: 0.85),
        height: height,
      );

  static TextStyle caption({
    double size = 12,
    Color? color,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.rajdhani(
        fontSize: size,
        fontWeight: FontWeight.w400,
        letterSpacing: letterSpacing,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle hudLabel({Color? color}) => GoogleFonts.orbitron(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.5,
        color: color ?? AppColors.primary.withValues(alpha: 0.55),
      );

  static TextStyle mono({
    double size = 10,
    Color? color,
    double letterSpacing = 0,
    FontWeight weight = FontWeight.w700,
  }) =>
      GoogleFonts.rajdhani(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color ?? AppColors.textPrimary,
      );
}

BoxDecoration glassCardDecoration({
  double borderAlpha = 0.55,
  double radius = AppLayout.cornerRadius,
  List<BoxShadow>? boxShadow,
  Color? borderColor,
}) =>
    BoxDecoration(
      border: Border.all(
        color: (borderColor ?? AppColors.primary)
            .withValues(alpha: borderAlpha),
        width: AppLayout.borderWidth * 0.5,
      ),
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surface.withValues(alpha: 0.40),
          AppColors.surfaceVariant.withValues(alpha: 0.12),
        ],
      ),
      boxShadow: boxShadow ??
          [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: AppEffects.glowOpacity),
              blurRadius: AppEffects.glowBlur,
              spreadRadius: AppEffects.glowSpread,
            ),
          ],
    );

Widget boardIconBtn(
  IconData icon,
  Color color,
  VoidCallback? onPressed,
  String tooltip,
) =>
    IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
    );

Widget readoutChip({required String label, required String value}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 1.0,
        ),
        color: AppColors.surface.withValues(alpha: 0.35),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.hudLabel()),
          const SizedBox(width: 8),
          Text(value, style: AppTypography.mono(size: 12)),
        ],
      ),
    );

const morphCurve = Cubic(0.16, 1.0, 0.3, 1.0);
const snapCurve = Cubic(0.22, 1.0, 0.36, 1.0);

double lerp(double a, double b, double t) => a + (b - a) * t;

ThemeData buildAppTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.rajdhaniTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
  );
}
