import '../models/study_entities.dart';
import '../models/study_plan.dart';
import '../models/study_session.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';

class PlansRepository {
  Future<StudyPlan?> fetchCurrentPlan() async {
    final response = await ApiClient.instance.client.get('/api/plans/current');
    if (response.data == null) {
      return null;
    }
    return StudyPlan.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<StudyPlan> generatePlan({
    required UserProfile profile,
    required List<CourseModel> courses,
    required List<ExamModel> exams,
    required List<AssignmentModel> assignments,
  }) async {
    final response = await ApiClient.instance.client.post(
      '/api/plans/generate',
      data: _payload(profile, courses, exams, assignments),
    );
    return StudyPlan.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<StudyPlan> recalculatePlan({
    required UserProfile profile,
    required List<CourseModel> courses,
    required List<ExamModel> exams,
    required List<AssignmentModel> assignments,
    required List<String> missedTaskIds,
    String? reason,
  }) async {
    final response = await ApiClient.instance.client.post(
      '/api/plans/recalculate',
      data: {
        ..._payload(profile, courses, exams, assignments),
        'missed_task_ids': missedTaskIds,
        'updated_deadlines': assignments.map((item) => item.toJson()).toList(),
        'reason': reason,
      },
    );
    return StudyPlan.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<List<StudySessionLog>> fetchSessions() async {
    final response = await ApiClient.instance.client.get('/api/plans/sessions');
    return (response.data as List<dynamic>? ?? const [])
        .map((item) => StudySessionLog.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<StudySessionLog> startSession({
    required StudyTask task,
  }) async {
    final response = await ApiClient.instance.client.post(
      '/api/plans/sessions/start',
      data: {
        'task_id': task.id,
        'title': task.title,
        'course_name': task.courseName,
        'planned_minutes': task.durationMinutes,
        'scheduled_start': task.scheduledStart,
      },
    );
    return StudySessionLog.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<StudySessionLog> completeSession({
    required String sessionId,
    required int actualMinutes,
    String? reflection,
  }) async {
    final response = await ApiClient.instance.client.post(
      '/api/plans/sessions/complete',
      data: {
        'session_id': sessionId,
        'actual_minutes': actualMinutes,
        'reflection': reflection,
      },
    );
    return StudySessionLog.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Map<String, dynamic> _payload(
    UserProfile profile,
    List<CourseModel> courses,
    List<ExamModel> exams,
    List<AssignmentModel> assignments,
  ) {
    return {
      'courses': courses.map((item) => item.toJson()).toList(),
      'exams': exams.map((item) => item.toJson()).toList(),
      'assignments': assignments.map((item) => item.toJson()).toList(),
      'context': {
        'preferred_study_hours': profile.preferredStudyHours,
        'preferred_study_times': profile.preferredStudyTimes,
        'weak_subjects': profile.weakSubjects,
        'learning_style': profile.learningStyle,
        'preferred_session_length': profile.preferredSessionLength,
      },
    };
  }
}
