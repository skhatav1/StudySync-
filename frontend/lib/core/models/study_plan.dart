class StudyRecommendation {
  const StudyRecommendation({
    required this.title,
    required this.reason,
    required this.urgency,
  });

  final String title;
  final String reason;
  final String urgency;

  factory StudyRecommendation.fromJson(Map<String, dynamic> json) => StudyRecommendation(
        title: json['title'] as String,
        reason: json['reason'] as String,
        urgency: json['urgency'] as String,
      );
}

class StudyTask {
  const StudyTask({
    required this.id,
    required this.title,
    required this.courseName,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.durationMinutes,
    required this.priority,
    required this.completed,
    required this.rationale,
  });

  final String id;
  final String title;
  final String courseName;
  final String scheduledStart;
  final String scheduledEnd;
  final int durationMinutes;
  final String priority;
  final bool completed;
  final String rationale;

  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
        id: json['id'] as String,
        title: json['title'] as String,
        courseName: json['course_name'] as String,
        scheduledStart: json['scheduled_start'] as String,
        scheduledEnd: json['scheduled_end'] as String,
        durationMinutes: json['duration_minutes'] as int,
        priority: json['priority'] as String,
        completed: json['completed'] as bool? ?? false,
        rationale: json['rationale'] as String,
      );
}

class StudyDayPlan {
  const StudyDayPlan({
    required this.date,
    required this.focusTheme,
    required this.breakStrategy,
    required this.sessions,
  });

  final String date;
  final String focusTheme;
  final String breakStrategy;
  final List<StudyTask> sessions;

  factory StudyDayPlan.fromJson(Map<String, dynamic> json) => StudyDayPlan(
        date: json['date'] as String,
        focusTheme: json['focus_theme'] as String,
        breakStrategy: json['break_strategy'] as String,
        sessions: (json['sessions'] as List<dynamic>? ?? const [])
            .map((item) => StudyTask.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(),
      );
}

class StudyPlan {
  const StudyPlan({
    required this.id,
    required this.headline,
    required this.weeklyGoal,
    required this.prioritizationSummary,
    required this.revisionIntervals,
    required this.recommendations,
    required this.dailyPlan,
  });

  final String id;
  final String headline;
  final String weeklyGoal;
  final List<String> prioritizationSummary;
  final Map<String, List<String>> revisionIntervals;
  final List<StudyRecommendation> recommendations;
  final List<StudyDayPlan> dailyPlan;

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    final revisionIntervalsRaw = Map<String, dynamic>.from(json['revision_intervals'] ?? const {});
    return StudyPlan(
      id: json['id'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      weeklyGoal: json['weekly_goal'] as String? ?? '',
      prioritizationSummary: List<String>.from(json['prioritization_summary'] ?? const []),
      revisionIntervals: revisionIntervalsRaw.map(
        (key, value) => MapEntry(key, List<String>.from(value as List<dynamic>)),
      ),
      recommendations: (json['recommendations'] as List<dynamic>? ?? const [])
          .map((item) => StudyRecommendation.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      dailyPlan: (json['daily_plan'] as List<dynamic>? ?? const [])
          .map((item) => StudyDayPlan.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}
