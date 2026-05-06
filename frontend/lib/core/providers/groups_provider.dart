import 'dart:async';

import 'package:flutter/material.dart';

import '../models/group_models.dart';
import '../repositories/groups_repository.dart';

class GroupsProvider extends ChangeNotifier {
  GroupsProvider(this._repository);

  final GroupsRepository _repository;
  List<StudyGroup> groups = const [];
  StreamSubscription<List<StudyGroup>>? _subscription;
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      groups = await _repository.fetchGroups();
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void bind() {
    _subscription?.cancel();
    _subscription = _repository.streamGroups().listen(
      (items) {
        groups = items;
        notifyListeners();
      },
      onError: (Object exc) {
        error = exc.toString();
        notifyListeners();
      },
    );
  }

  Future<void> createGroup({
    required String name,
    required String subject,
    required String sharedGoal,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final group = await _repository.createGroup(
          name: name, subject: subject, sharedGoal: sharedGoal);
      groups = [group, ...groups.where((item) => item.id != group.id)];
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Stream<List<GroupTask>> streamGroupTasks(String groupId) =>
      _repository.streamGroupTasks(groupId);

  Stream<List<CommentItem>> streamGroupComments(String groupId) =>
      _repository.streamGroupComments(groupId);

  Future<void> createTask({
    required String groupId,
    required String title,
    required String dueDate,
    List<String> assignedTo = const [],
  }) {
    return _repository.createTask(
      groupId: groupId,
      title: title,
      dueDate: dueDate,
      assignedTo: assignedTo,
    );
  }

  Future<void> toggleTask(GroupTask task) => _repository.toggleTask(task);

  Future<void> deleteTask(String taskId) => _repository.deleteTask(taskId);

  Future<void> addComment({
    required String groupId,
    required String resourceId,
    required String text,
  }) {
    return _repository.addComment(
        groupId: groupId, resourceId: resourceId, text: text);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
