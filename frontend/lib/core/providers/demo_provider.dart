import 'package:flutter/material.dart';

import '../models/study_entities.dart';
import '../models/user_profile.dart';
import '../repositories/demo_seed_repository.dart';

class DemoProvider extends ChangeNotifier {
  DemoProvider(this._repository);

  final DemoSeedRepository _repository;
  bool loading = false;
  String? error;

  Future<void> seedWorkspace({
    required UserProfile profile,
    required List<CourseModel> courses,
    required List<ExamModel> exams,
    required List<AssignmentModel> assignments,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _repository.seedWorkspace(
        profile: profile,
        courses: courses,
        exams: exams,
        assignments: assignments,
      );
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
