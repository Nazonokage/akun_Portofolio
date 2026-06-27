import 'package:flutter/material.dart';

BoxDecoration glassCardDecoration({
  double borderAlpha = 0.55,
  double radius = 12,
  List<BoxShadow>? boxShadow,
}) =>
    BoxDecoration(
      border: Border.all(color: AppColors.grid.withValues(alpha: borderAlpha)),
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.frame.withValues(alpha: 0.40),
          AppColors.grid.withValues(alpha: 0.12),
        ],
      ),
      boxShadow: boxShadow,
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
          color: AppColors.neonGlow.withValues(alpha: 0.18),
          width: 1.0,
        ),
        color: AppColors.frame.withValues(alpha: 0.35),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGlow.withValues(alpha: 0.06),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 2.2,
              color: AppColors.neonGlow.withValues(alpha: 0.65),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );

// ─── Palette ────────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF04090F);
  static const surface = Color(0xFF081422);
  static const frame = Color(0xFF0C1E36);
  static const grid = Color(0xFF0E3A50);
  static const neonGlow = Color(0xFF52EBD9);
  static const hologram = Color(0xFF44C5B8);
  static const secondaryGlow = Color(0xFF43AAA4);
  static const teamA = Color(0xFF52EBD9);
  static const teamB = Color(0xFFFF4D6D);
  static const accent2 = Color(0xFF6C63FF);
  static const accent3 = Color(0xFFFF9F43);
  static const gold = Color(0xFFFFD166);
}

const morphCurve = Cubic(0.16, 1.0, 0.3, 1.0);
const snapCurve = Cubic(0.22, 1.0, 0.36, 1.0);

double lerp(double a, double b, double t) => a + (b - a) * t;
