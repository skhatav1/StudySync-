class StudySessionLog {
  const StudySessionLog({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.title,
    required this.courseName,
    required this.plannedMinutes,
    required this.scheduledStart,
    required this.startedAt,
    required this.actualMinutes,
    required this.completed,
    required this.reflection,
  });

  final String id;
  final String userId;
  final String taskId;
  final String title;
  final String courseName;
  final int plannedMinutes;
  final String scheduledStart;
  final String startedAt;
  final int actualMinutes;
  final bool completed;
  final String? reflection;

  factory StudySessionLog.fromJson(Map<String, dynamic> json) => StudySessionLog(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        taskId: json['task_id'] as String,
        title: json['title'] as String,
        courseName: json['course_name'] as String,
        plannedMinutes: json['planned_minutes'] as int,
        scheduledStart: json['scheduled_start'] as String,
        startedAt: json['started_at'] as String,
        actualMinutes: json['actual_minutes'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
        reflection: json['reflection'] as String?,
      );
}
