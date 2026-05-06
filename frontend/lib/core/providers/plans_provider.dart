import 'package:flutter/material.dart';

import '../models/study_entities.dart';
import '../models/study_plan.dart';
import '../models/user_profile.dart';
import '../repositories/plans_repository.dart';

class PlansProvider extends ChangeNotifier {
  PlansProvider(this._repository);

  final PlansRepository _repository;
  StudyPlan? plan;
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      plan = await _repository.fetchCurrentPlan();
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> generate({
    required UserProfile profile,
    required List<CourseModel> courses,
    required List<ExamModel> exams,
    required List<AssignmentModel> assignments,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      plan = await _repository.generatePlan(
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

  Future<void> recalculate({
    required UserProfile profile,
    required List<CourseModel> courses,
    required List<ExamModel> exams,
    required List<AssignmentModel> assignments,
    required List<String> missedTaskIds,
    String? reason,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      plan = await _repository.recalculatePlan(
        profile: profile,
        courses: courses,
        exams: exams,
        assignments: assignments,
        missedTaskIds: missedTaskIds,
        reason: reason,
      );
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
