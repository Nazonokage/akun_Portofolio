import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// ─── Scroll Progress Bar ──────────────────────────────────────────────────
class ScrollProgressBar extends StatelessWidget {
  final double progress;
  const ScrollProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.frame.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonGlow.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGlow.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.compare_arrows, color: AppColors.neonGlow, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.grid.withValues(alpha: 0.3),
                color: AppColors.neonGlow,
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.neonGlow,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

