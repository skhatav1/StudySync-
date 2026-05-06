import 'package:flutter/material.dart';

import '../models/study_plan.dart';
import '../models/study_session.dart';
import '../repositories/plans_repository.dart';

class StudySessionsProvider extends ChangeNotifier {
  StudySessionsProvider(this._repository);

  final PlansRepository _repository;
  List<StudySessionLog> sessions = const [];
  StudySessionLog? activeSession;
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      sessions = await _repository.fetchSessions();
      final incomplete = sessions.where((session) => !session.completed).toList();
      activeSession = incomplete.isNotEmpty ? incomplete.first : null;
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> start(StudyTask task) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _repository.startSession(task: task);
      await load();
    } catch (exc) {
      error = exc.toString();
      loading = false;
      notifyListeners();
    }
  }

  Future<void> complete({
    required String sessionId,
    required int actualMinutes,
    String? reflection,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _repository.completeSession(
        sessionId: sessionId,
        actualMinutes: actualMinutes,
        reflection: reflection,
      );
      await load();
    } catch (exc) {
      error = exc.toString();
      loading = false;
      notifyListeners();
    }
  }
}
