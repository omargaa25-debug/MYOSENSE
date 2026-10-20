class RunResult {
  final Duration time;
  final double km;
  final String avgPace;
  final int peakFatigue;
  final int avgFatigue;
  final int kcal;
  final int laps;
  final int recoveryHours;
  final List<double> fatigueCurve;

  const RunResult({
    required this.time,
    required this.km,
    required this.avgPace,
    required this.peakFatigue,
    required this.avgFatigue,
    required this.kcal,
    required this.laps,
    required this.recoveryHours,
    required this.fatigueCurve,
  });
}
