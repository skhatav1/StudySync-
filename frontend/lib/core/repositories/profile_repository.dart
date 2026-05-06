import 'package:firebase_auth/firebase_auth.dart';

import '../models/study_entities.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';

class ProfileRepository {
  ProfileRepository();

  Future<UserProfile?> fetchProfile() async {
    final response = await ApiClient.instance.client.get('/api/profile/me');
    if (response.data == null) {
      return null;
    }
    return UserProfile.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<List<CourseModel>> fetchCourses() async {
    final data = await _fetchOnboardingData();
    return (data['courses'] as List<dynamic>? ?? const [])
        .map(
          (item) {
            final json = Map<String, dynamic>.from(item as Map);
            return CourseModel(
            id: json['id'] as String?,
            name: json['name'] as String? ?? '',
            currentGrade: json['current_grade'] as String?,
            confidence: json['confidence'] as int? ?? 5,
          );
          },
        )
        .toList();
  }

  Future<List<ExamModel>> fetchExams() async {
    final data = await _fetchOnboardingData();
    return (data['exams'] as List<dynamic>? ?? const [])
        .map(
          (item) {
            final json = Map<String, dynamic>.from(item as Map);
            return ExamModel(
            id: json['id'] as String?,
            courseName: json['course_name'] as String? ?? '',
            title: json['title'] as String? ?? '',
            examDate: json['exam_date'] as String? ?? '',
            targetScore: json['target_score'] as String?,
          );
          },
        )
        .toList();
  }

  Future<List<AssignmentModel>> fetchAssignments() async {
    final data = await _fetchOnboardingData();
    return (data['assignments'] as List<dynamic>? ?? const [])
        .map(
          (item) {
            final json = Map<String, dynamic>.from(item as Map);
            return AssignmentModel(
            id: json['id'] as String?,
            courseName: json['course_name'] as String? ?? '',
            title: json['title'] as String? ?? '',
            dueDate: json['due_date'] as String? ?? '',
            estimatedHours: (json['estimated_hours'] as num?)?.toDouble() ?? 1,
            priority: json['priority'] as String? ?? 'medium',
          );
          },
        )
        .toList();
  }

  Future<Map<String, dynamic>> _fetchOnboardingData() async {
    final response = await ApiClient.instance.client.get('/api/profile/onboarding-data');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> ensureProfile(User user) async {
    await ApiClient.instance.client.post(
      '/api/profile/',
      data: {
        'uid': user.uid,
        'name': user.displayName ?? 'Student',
        'email': user.email,
        'academic_goals': <String>[],
        'preferred_study_hours': 3,
        'learning_style': 'mixed',
        'weak_subjects': <String>[],
        'preferred_session_length': 50,
        'preferred_study_times': <String>[],
        'target_grades': <String, String>{},
        'collaboration_preferences': <String>[],
      },
    );
  }

  Future<void> saveOnboarding({
    required UserProfile profile,
    required List<CourseModel> courses,
    required List<ExamModel> exams,
    required List<AssignmentModel> assignments,
  }) async {
    await ApiClient.instance.client.post(
      '/api/profile/onboarding',
      data: {
        'profile': {
          'name': profile.name,
          'academic_goals': profile.academicGoals,
          'preferred_study_hours': profile.preferredStudyHours,
          'learning_style': profile.learningStyle,
          'weak_subjects': profile.weakSubjects,
          'preferred_session_length': profile.preferredSessionLength,
          'preferred_study_times': profile.preferredStudyTimes,
          'target_grades': profile.targetGrades,
          'collaboration_preferences': profile.collaborationPreferences,
        },
        'courses': courses.map((item) => item.toJson()).toList(),
        'exams': exams.map((item) => item.toJson()).toList(),
        'assignments': assignments.map((item) => item.toJson()).toList(),
      },
    );
  }
}
