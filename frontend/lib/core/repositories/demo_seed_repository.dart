import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/study_entities.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';

class DemoSeedRepository {
  DemoSeedRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> seedWorkspace({
    required UserProfile profile,
    required List<CourseModel> courses,
    required List<ExamModel> exams,
    required List<AssignmentModel> assignments,
  }) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('notifications').add({
      'user_id': uid,
      'title': 'Plan recalculation suggestion',
      'body': 'You have two deadlines this week. Rebuild your study plan after tonight’s session.',
      'type': 'plan',
      'created_at': DateTime.now().toIso8601String(),
      'read': false,
    });
    await _firestore.collection('notifications').add({
      'user_id': uid,
      'title': 'Study group activity',
      'body': 'Maya added graph traversal notes to Algorithm Sprint Crew.',
      'type': 'group',
      'created_at': DateTime.now().toIso8601String(),
      'read': false,
    });
    await ApiClient.instance.client.post(
      '/api/groups/',
      data: {
        'name': 'Algorithm Sprint Crew',
        'subject': 'Data Structures',
        'shared_goal': 'Finish graphs and run a mock whiteboard round.',
      },
    );
    await ApiClient.instance.client.post(
      '/api/resources/',
      data: {
        'title': 'Integration Techniques Summary.pdf',
        'subject': 'Calculus',
        'topic': 'Integration',
        'storage_path': 'demo/resources/integration-techniques-summary.pdf',
        'download_url': 'https://example.com/demo/integration-techniques-summary.pdf',
        'mime_type': 'application/pdf',
        'tags': ['exam', 'weak-area'],
        'favorite': true,
      },
    );
    await ApiClient.instance.client.post(
      '/api/plans/generate',
      data: {
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
      },
    );
  }
}
