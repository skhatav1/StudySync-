import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/group_models.dart';
import '../services/api_client.dart';

class GroupsRepository {
  GroupsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<StudyGroup>> fetchGroups() async {
    final response = await ApiClient.instance.client.get('/api/groups/');
    return (response.data as List<dynamic>? ?? const [])
        .map((item) =>
            StudyGroup.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Stream<List<StudyGroup>> streamGroups() {
    return _firestore.collection('study_groups').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => StudyGroup.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  Stream<List<GroupTask>> streamGroupTasks(String groupId) {
    return _firestore
        .collection('group_tasks')
        .where('group_id', isEqualTo: groupId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GroupTask.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  Stream<List<CommentItem>> streamGroupComments(String groupId) {
    return _firestore
        .collection('comments')
        .where('group_id', isEqualTo: groupId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentItem.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  Future<StudyGroup> createGroup({
    required String name,
    required String subject,
    required String sharedGoal,
  }) async {
    final response = await ApiClient.instance.client.post(
      '/api/groups/',
      data: {
        'name': name,
        'subject': subject,
        'shared_goal': sharedGoal,
      },
    );
    return StudyGroup.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> createTask({
    required String groupId,
    required String title,
    required String dueDate,
    List<String> assignedTo = const [],
  }) async {
    await ApiClient.instance.client.post(
      '/api/groups/$groupId/tasks',
      data: {
        'title': title,
        'due_date': dueDate,
        'assigned_to': assignedTo,
        'completed': false,
      },
    );
  }

  Future<void> toggleTask(GroupTask task) async {
    await ApiClient.instance.client.patch(
      '/api/groups/tasks/${task.id}',
      data: {'completed': !task.completed},
    );
  }

  Future<void> deleteTask(String taskId) async {
    await ApiClient.instance.client.delete('/api/groups/tasks/$taskId');
  }

  Future<void> addComment({
    required String groupId,
    required String resourceId,
    required String text,
  }) async {
    await ApiClient.instance.client.post(
      '/api/groups/$groupId/comments',
      data: {'resource_id': resourceId, 'text': text},
    );
  }
}
