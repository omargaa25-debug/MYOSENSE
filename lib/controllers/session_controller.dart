import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/format.dart';
import '../models/run_result.dart';

enum RunPhase { idle, countdown, running, paused, finished }

enum TearRisk { low, medium, high }

/// Données simulées. Plus tard : GPS pour la distance, patch + IA pour la fatigue.
class SessionController extends ChangeNotifier {
  /// Accélère la simulation pour tester vite (1 = temps réel).
  static const double demoBoost = 4;

  RunPhase phase = RunPhase.idle;
  int countdown = 3;
  Duration elapsed = Duration.zero;
  double distanceM = 0;
  double fatigue = 8; // 0 à 100
  double speed = 3.2; // m/s
  double medianFreq = 96; // Hz
  int laps = 0;
  RunResult? result;

  final List<double> _curve = [];
  double _peak = 8;
  double _fatigueSum = 0;
  int _samples = 0;
  int _ticks = 0;
  Duration _lastTick = Duration.zero;

  final Stopwatch _sw = Stopwatch();
  final math.Random _rng = math.Random();
  Timer? _timer;
  Timer? _cd;

  // ---------- valeurs affichées ----------
  double get km => distanceM / 1000;
  double get paceSecPerKm => speed > 0 ? 1000 / speed : 0;

  TearRisk get tearRisk => fatigue < 70
      ? TearRisk.low
      : (fatigue < 85 ? TearRisk.medium : TearRisk.high);

  String get fatigueLabel => fatigue < 35
      ? 'Fresh'
      : (fatigue < 70 ? 'Moderate' : (fatigue < 85 ? 'High' : 'Very high'));

  String get coachMessage {
    if (phase == RunPhase.paused) {
      return 'Run paused. Breathe, your muscles are recovering.';
    }
    if (_peak < 25)
      return 'Great rhythm. Your muscles are fresh, keep this cadence.';
    if (_peak < 55)
      return 'Muscle activity is steady. Keep your stride relaxed.';
    if (_peak < 70) {
      return 'Your quad is tiring faster than usual. Shorten your stride for the next 500 m.';
    }
    if (_peak < 85) {
      return 'Fatigue is rising fast. Slow down a little and keep your cadence high.';
    }
    return 'High tear risk. Slow to a walk now and stretch gently.';
  }

  // ---------- compte à rebours ----------
  void startCountdown() {
    if (phase != RunPhase.idle) return;
    phase = RunPhase.countdown;
    countdown = 3;
    HapticFeedback.selectionClick();
    notifyListeners();
    _cd?.cancel();
    _cd = Timer.periodic(const Duration(seconds: 1), (t) {
      countdown--;
      if (countdown > 0) {
        HapticFeedback.selectionClick();
      } else {
        HapticFeedback.heavyImpact();
      }
      notifyListeners();
      if (countdown <= 0) {
        t.cancel();
        _cd = Timer(const Duration(milliseconds: 800), _begin);
      }
    });
  }

  void cancelCountdown() {
    if (phase != RunPhase.countdown) return;
    _cd?.cancel();
    phase = RunPhase.idle;
    notifyListeners();
  }

  // ---------- course ----------
  void _begin() {
    if (phase != RunPhase.countdown) return;
    elapsed = Duration.zero;
    distanceM = 0;
    fatigue = 8;
    speed = 3.2;
    medianFreq = 96;
    laps = 0;
    result = null;
    _curve.clear();
    _peak = 8;
    _fatigueSum = 0;
    _samples = 0;
    _ticks = 0;
    _lastTick = Duration.zero;
    _sw
      ..reset()
      ..start();
    phase = RunPhase.running;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), _tick);
    notifyListeners();
  }

  void _tick(Timer _) {
    if (phase != RunPhase.running) return;
    final now = _sw.elapsed;
    final dt = (now - _lastTick).inMilliseconds / 1000.0;
    _lastTick = now;
    elapsed = now;

    final simSec = now.inMilliseconds / 1000.0 * demoBoost;
    final target = 8 + 70 * (1 - math.exp(-simSec / 120));
    fatigue =
        (fatigue + (target - fatigue) * 0.05 + (_rng.nextDouble() - 0.5) * 0.3)
            .clamp(0.0, 100.0);

    final targetSpeed = 3.2 * (1 - fatigue / 100 * 0.12);
    speed += (targetSpeed - speed) * 0.05 + (_rng.nextDouble() - 0.5) * 0.04;
    distanceM += speed * dt * demoBoost;
    medianFreq = 96 - fatigue * 0.28 + (_rng.nextDouble() - 0.5) * 0.4;

    if (fatigue > _peak) _peak = fatigue;
    _fatigueSum += fatigue;
    _samples++;
    _ticks++;
    if (_ticks % 10 == 0) _curve.add(fatigue);
    notifyListeners();
  }

  void togglePause() {
    if (phase == RunPhase.running) {
      _sw.stop();
      phase = RunPhase.paused;
    } else if (phase == RunPhase.paused) {
      _sw.start();
      _lastTick = _sw.elapsed;
      phase = RunPhase.running;
    } else {
      return;
    }
    notifyListeners();
  }

  String lap() {
    laps++;
    return 'Lap $laps · ${formatPace(paceSecPerKm)} /km';
  }

  void finish() {
    if (phase != RunPhase.running && phase != RunPhase.paused) return;
    _timer?.cancel();
    _sw.stop();
    final distance = distanceM / 1000;
    result = RunResult(
      time: elapsed,
      km: distance,
      avgPace: distance > 0.01
          ? formatPace(elapsed.inSeconds / distance)
          : '--:--',
      peakFatigue: _peak.round(),
      avgFatigue: _samples > 0 ? (_fatigueSum / _samples).round() : 0,
      kcal: (distance * 62).round(),
      laps: laps,
      recoveryHours: (6 + _peak * 0.3).round(),
      fatigueCurve: List.of(_curve),
    );
    phase = RunPhase.finished;
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _cd?.cancel();
    _sw
      ..stop()
      ..reset();
    phase = RunPhase.idle;
    result = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cd?.cancel();
    super.dispose();
  }
}
