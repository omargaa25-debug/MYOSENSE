import 'package:flutter/material.dart';
import 'theme.dart';

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

String formatPace(double secPerKm) {
  if (secPerKm.isNaN ||
      secPerKm.isInfinite ||
      secPerKm <= 0 ||
      secPerKm > 3599) {
    return '--:--';
  }
  final total = secPerKm.round();
  return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
}

/// lime -> orange -> rouge selon la fatigue (0 à 100)
Color fatigueColor(double f) {
  if (f < 80) {
    return Color.lerp(
      AppColors.volt,
      AppColors.warning,
      ((f - 62) / 12).clamp(0.0, 1.0),
    )!;
  }
  return Color.lerp(
    AppColors.warning,
    AppColors.danger,
    ((f - 80) / 10).clamp(0.0, 1.0),
  )!;
}
