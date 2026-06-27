import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class JumpToContactButton extends StatelessWidget {
  final VoidCallback onPressed;

  const JumpToContactButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 24,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.neonGlow.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.frame.withValues(alpha: 0.85),
                    AppColors.grid.withValues(alpha: 0.35),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGlow.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 16,
                    color: AppColors.neonGlow.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CONTACT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.neonGlow.withValues(alpha: 0.9),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
