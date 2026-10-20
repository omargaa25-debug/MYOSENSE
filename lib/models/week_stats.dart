class WeekStats {
  final double km;
  final int runs;
  final String totalTime;
  final String avgPace;
  final List<double> dailyKm; // lundi -> dimanche
  final int todayIndex;

  const WeekStats({
    required this.km,
    required this.runs,
    required this.totalTime,
    required this.avgPace,
    required this.dailyKm,
    required this.todayIndex,
  });
}

class Challenge {
  final String title;
  final double goalKm;
  final double doneKm;

  const Challenge({
    required this.title,
    required this.goalKm,
    required this.doneKm,
  });

  double get progress => (doneKm / goalKm).clamp(0.0, 1.0);
}
