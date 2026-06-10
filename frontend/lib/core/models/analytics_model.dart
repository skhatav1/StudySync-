class AnalyticsSummary {
  const AnalyticsSummary({
    required this.streakDays,
    required this.hoursStudied,
    required this.tasksCompleted,
    required this.completionRate,
    required this.weakSubjects,
    required this.upcomingDeadlines,
    required this.productivityScore,
    required this.aiInsights,
    required this.weeklyHours,
  });

  final int streakDays;
  final double hoursStudied;
  final int tasksCompleted;
  final double completionRate;
  final List<String> weakSubjects;
  final List<String> upcomingDeadlines;
  final int productivityScore;
  final List<String> aiInsights;
  /// Hours studied per day for the current week, Mon–Sun (7 values).
  final List<double> weeklyHours;

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    final rawWeekly = json['weekly_hours'];
    final weeklyHours = rawWeekly is List
        ? rawWeekly.map((v) => (v as num).toDouble()).toList()
        : List<double>.filled(7, 0);
    return AnalyticsSummary(
      streakDays: json['streak_days'] as int? ?? 0,
      hoursStudied: (json['hours_studied'] as num?)?.toDouble() ?? 0,
      tasksCompleted: json['tasks_completed'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0,
      weakSubjects: List<String>.from(json['weak_subjects'] ?? const []),
      upcomingDeadlines: List<String>.from(json['upcoming_deadlines'] ?? const []),
      productivityScore: json['productivity_score'] as int? ?? 0,
      aiInsights: List<String>.from(json['ai_insights'] ?? const []),
      weeklyHours: weeklyHours.length == 7 ? weeklyHours : List<double>.filled(7, 0),
    );
  }
}
