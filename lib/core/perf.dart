import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// ─── Performance tier (mobile web / reduce motion) ───────────────────────
final animationsPaused = ValueNotifier<bool>(false);

class Perf {
  static bool _mobileWebChecked = false;
  static bool _isMobileWeb = false;

  static bool get isMobileWeb {
    if (!_mobileWebChecked) {
      _mobileWebChecked = true;
      if (kIsWeb) {
        final view = WidgetsBinding.instance.platformDispatcher.views.first;
        final logicalShortest =
            view.physicalSize.shortestSide / view.devicePixelRatio;
        _isMobileWeb = logicalShortest < 600;
      }
    }
    return _isMobileWeb;
  }

  static bool get reduceMotion =>
      WidgetsBinding
          .instance
          .platformDispatcher
          .accessibilityFeatures
          .disableAnimations;

  static bool get lightEffects => isMobileWeb || reduceMotion;

  static bool get enableScanLine => !lightEffects;
  static bool get enableLevitate => !lightEffects;
  static bool get enableAuroraAnim => !lightEffects;
  static bool get useBlur => !lightEffects;
  static int get particleCount => lightEffects ? 5 : 16;
}

