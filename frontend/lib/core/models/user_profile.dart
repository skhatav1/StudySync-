class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.academicGoals,
    required this.preferredStudyHours,
    required this.learningStyle,
    required this.weakSubjects,
    required this.preferredSessionLength,
    required this.preferredStudyTimes,
    required this.targetGrades,
    required this.collaborationPreferences,
  });

  final String uid;
  final String name;
  final String email;
  final List<String> academicGoals;
  final double preferredStudyHours;
  final String learningStyle;
  final List<String> weakSubjects;
  final int preferredSessionLength;
  final List<String> preferredStudyTimes;
  final Map<String, String> targetGrades;
  final List<String> collaborationPreferences;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      academicGoals: List<String>.from(json['academic_goals'] ?? const []),
      preferredStudyHours: (json['preferred_study_hours'] as num?)?.toDouble() ?? 3,
      learningStyle: json['learning_style'] as String? ?? 'mixed',
      weakSubjects: List<String>.from(json['weak_subjects'] ?? const []),
      preferredSessionLength: json['preferred_session_length'] as int? ?? 50,
      preferredStudyTimes: List<String>.from(json['preferred_study_times'] ?? const []),
      targetGrades: Map<String, String>.from(json['target_grades'] ?? const {}),
      collaborationPreferences: List<String>.from(json['collaboration_preferences'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'academic_goals': academicGoals,
      'preferred_study_hours': preferredStudyHours,
      'learning_style': learningStyle,
      'weak_subjects': weakSubjects,
      'preferred_session_length': preferredSessionLength,
      'preferred_study_times': preferredStudyTimes,
      'target_grades': targetGrades,
      'collaboration_preferences': collaborationPreferences,
    };
  }
}
