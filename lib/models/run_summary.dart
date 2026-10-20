import 'dart:ui';

class RunSummary {
  final String title;
  final String when;
  final double km;
  final String pace; // min/km
  final String time;
  final int peakFatigue; // en %
  final int alerts;
  final List<Offset> route; // points normalisés entre 0 et 1

  const RunSummary({
    required this.title,
    required this.when,
    required this.km,
    required this.pace,
    required this.time,
    required this.peakFatigue,
    required this.alerts,
    required this.route,
  });

  bool get isHigh => peakFatigue >= 75;

  String get statusText {
    if (isHigh) {
      return 'Peak fatigue $peakFatigue% · $alerts alert${alerts > 1 ? 's' : ''}';
    }
    return 'Peak fatigue $peakFatigue% · normal';
  }
}
