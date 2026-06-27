import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─── Formation Detection ──────────────────────────────────────────────────
class FormationAnalyzer {
  static String detect(List<Offset> positions, double pitchWidth) {
    if (positions.length < 10) return "4-2-3-1";
    final nonGk = positions.skip(1).toList();
    if (nonGk.length < 9) return "4-2-3-1";

    final xValues = (List<Offset>.from(
      nonGk,
    )..sort((a, b) => a.dx.compareTo(b.dx))).map((p) => p.dx).toList();
    final clusters = _kMeansOptimized(xValues, 3);
    final counts = List.filled(3, 0);
    for (final idx in clusters) {
      counts[idx]++;
    }

    final avgs = _clusterAvgs(xValues, clusters, 3);
    final order = List.generate(3, (i) => i)
      ..sort((a, b) => avgs[a].compareTo(avgs[b]));
    return '${counts[order[0]]}-${counts[order[1]]}-${counts[order[2]]}';
  }

  static List<double> getBandAveragesX(
    List<Offset> positions,
    double pitchWidth,
  ) {
    if (positions.length < 10) return [pitchWidth * 0.33, pitchWidth * 0.66];
    final nonGk = positions.skip(1).toList();
    if (nonGk.length < 9) return [pitchWidth * 0.33, pitchWidth * 0.66];

    final xValues = (List<Offset>.from(
      nonGk,
    )..sort((a, b) => a.dx.compareTo(b.dx))).map((p) => p.dx).toList();
    final avgs = _clusterAvgs(xValues, _kMeansOptimized(xValues, 3), 3)..sort();
    return avgs;
  }

  static List<double> _clusterAvgs(
    List<double> data,
    List<int> labels,
    int k,
  ) => List.generate(k, (i) {
    double sum = 0.0;
    int count = 0;
    for (int j = 0; j < data.length; j++) {
      if (labels[j] == i) {
        sum += data[j];
        count++;
      }
    }
    return count > 0 ? sum / count : 0.0;
  });

  static List<int> _kMeansOptimized(List<double> data, int k) {
    if (data.isEmpty) return [];
    final minVal = data.reduce(math.min);
    final step = (data.reduce(math.max) - minVal) / (k - 1);
    var centroids = List.generate(k, (i) => minVal + i * step);
    final labels = List.filled(data.length, 0);
    bool changed = true;
    while (changed) {
      changed = false;
      for (int i = 0; i < data.length; i++) {
        double minDist = double.infinity;
        int best = 0;
        for (int j = 0; j < k; j++) {
          final dist = (data[i] - centroids[j]).abs();
          if (dist < minDist) {
            minDist = dist;
            best = j;
          }
        }
        if (labels[i] != best) {
          labels[i] = best;
          changed = true;
        }
      }
      final sums = List.filled(k, 0.0);
      final counts = List.filled(k, 0);
      for (int i = 0; i < data.length; i++) {
        final label = labels[i];
        sums[label] += data[i];
        counts[label]++;
      }
      for (int j = 0; j < k; j++) {
        if (counts[j] > 0) centroids[j] = sums[j] / counts[j];
      }
    }
    return labels;
  }
}

// ─── Position / Jersey Data ──────────────────────────────────────────────
const positionLabels = [
  'GK',
  'LB',
  'CB',
  'CB',
  'RB',
  'CDM',
  'CDM',
  'LW',
  'CAM',
  'RW',
  'ST',
];
const jerseyNumbers = [1, 2, 3, 4, 5, 6, 8, 7, 10, 11, 9];

final defaultPositions = [
  (w, h) => Offset(w * 0.07, h / 2),
  (w, h) => Offset(w * 0.21, h * 0.10),
  (w, h) => Offset(w * 0.21, h * 0.38),
  (w, h) => Offset(w * 0.21, h * 0.62),
  (w, h) => Offset(w * 0.21, h * 0.90),
  (w, h) => Offset(w * 0.36, h * 0.38),
  (w, h) => Offset(w * 0.36, h * 0.62),
  (w, h) => Offset(w * 0.50, h * 0.22),
  (w, h) => Offset(w * 0.50, h / 2),
  (w, h) => Offset(w * 0.50, h * 0.78),
  (w, h) => Offset(w * 0.62, h / 2),
];

