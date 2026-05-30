import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/study_entities.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository);

  final ProfileRepository _repository;
  UserProfile? profile;
  List<CourseModel> courses = const [];
  List<ExamModel> exams = const [];
  List<AssignmentModel> assignments = const [];
  bool loading = false;
  bool hasLoaded = false;
  String? error;
  String? loadedUid;

  bool get needsOnboarding {
    if (profile == null) return true;
    return profile!.academicGoals.isEmpty && courses.isEmpty && exams.isEmpty && assignments.isEmpty;
  }

  Future<void> load(User user) async {
    loading = true;
    hasLoaded = false;
    loadedUid = user.uid;
    profile = null;
    courses = const [];
    exams = const [];
    assignments = const [];
    error = null;
    notifyListeners();
    try {
      await _repository.ensureProfile(user);
      profile = await _repository.fetchProfile();
      courses = await _repository.fetchCourses();
      exams = await _repository.fetchExams();
      assignments = await _repository.fetchAssignments();
      hasLoaded = true;
    } catch (exc) {
      error = exc.toString();
      hasLoaded = true;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> saveOnboarding({
    required UserProfile updatedProfile,
    required List<CourseModel> newCourses,
    required List<ExamModel> newExams,
    required List<AssignmentModel> newAssignments,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _repository.saveOnboarding(
        profile: updatedProfile,
        courses: newCourses,
        exams: newExams,
        assignments: newAssignments,
      );
      profile = updatedProfile;
      courses = newCourses;
      exams = newExams;
      assignments = newAssignments;
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void seedDemoFields(User user) {
    if (profile != null && profile!.uid != user.uid) {
      clear();
    }
    profile ??= UserProfile(
      uid: user.uid,
      name: user.displayName ?? 'Student',
      email: user.email ?? '',
      academicGoals: const [],
      preferredStudyHours: 3,
      learningStyle: 'mixed',
      weakSubjects: const [],
      preferredSessionLength: 50,
      preferredStudyTimes: const [],
      targetGrades: const {},
      collaborationPreferences: const [],
    );
  }

  void clear() {
    profile = null;
    courses = const [];
    exams = const [];
    assignments = const [];
    loading = false;
    hasLoaded = false;
    error = null;
    loadedUid = null;
  }
}
