import 'package:flutter/material.dart';

// ─── Shared Text Layout Cache (capped LRU) ────────────────────────────────
class LRUTextCache {
  static const _maxSize = 50;
  static final _cache = <String, TextPainter>{};
  static final _order = <String>[];

  static TextPainter get(String text, TextStyle style) {
    final key = '$text-${style.hashCode}';
    if (_cache.containsKey(key)) {
      _order.remove(key);
      _order.add(key);
      return _cache[key]!;
    }
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    if (_cache.length >= _maxSize) {
      final oldest = _order.removeAt(0);
      _cache.remove(oldest);
    }
    _cache[key] = painter;
    _order.add(key);
    return painter;
  }

  static void clear() {
    _cache.clear();
    _order.clear();
  }
}

TextPainter layoutText(String text, TextStyle style) =>
    LRUTextCache.get(text, style);

void paintText(Canvas canvas, String text, TextStyle style, Offset offset) {
  layoutText(text, style).paint(canvas, offset);
}

