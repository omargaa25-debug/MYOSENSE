import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/run_summary.dart';
import '../models/week_stats.dart';

/// Données simulées. Plus tard : historique réel + état réel du patch.
class HomeController extends ChangeNotifier {
  final bool patchConnected = true;
  final int patchBattery = 86;
  final bool hasNotifications = true;

  final WeekStats week = const WeekStats(
    km: 19.6,
    runs: 3,
    totalTime: '1h 52',
    avgPace: '5:27',
    dailyKm: [4.2, 0, 6.0, 0, 0, 9.4, 0],
    todayIndex: 5,
  );

  final List<RunSummary> recentRuns = const [
    RunSummary(
      title: 'Evening run',
      when: 'Sat · 18:40',
      km: 9.4,
      pace: '5:21',
      time: '50:18',
      peakFatigue: 84,
      alerts: 1,
      route: [
        Offset(0.10, 0.85),
        Offset(0.30, 0.55),
        Offset(0.50, 0.20),
        Offset(0.75, 0.12),
        Offset(0.90, 0.30),
        Offset(0.55, 0.65),
        Offset(0.30, 0.90),
        Offset(0.10, 0.85),
      ],
    ),
    RunSummary(
      title: 'Morning run',
      when: 'Wed · 07:15',
      km: 6.0,
      pace: '5:34',
      time: '33:24',
      peakFatigue: 52,
      alerts: 0,
      route: [
        Offset(0.00, 0.80),
        Offset(0.20, 0.80),
        Offset(0.28, 0.25),
        Offset(0.55, 0.30),
        Offset(0.88, 0.45),
        Offset(0.80, 0.78),
        Offset(0.55, 0.88),
        Offset(0.30, 0.80),
      ],
    ),
  ];

  final Challenge challenge = const Challenge(
    title: 'October challenge · 100 km',
    goalKm: 100,
    doneKm: 64,
  );
}
