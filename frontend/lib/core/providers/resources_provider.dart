import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/group_models.dart';
import '../models/resource_models.dart';
import '../repositories/resources_repository.dart';

class ResourcesProvider extends ChangeNotifier {
  ResourcesProvider(this._repository);

  final ResourcesRepository _repository;
  List<ResourceItem> resources = const [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      resources = await _repository.fetchResources();
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> upload({
    required PlatformFile file,
    required String subject,
    required String topic,
    required List<String> tags,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final item = await _repository.uploadResource(
        file: file,
        subject: subject,
        topic: topic,
        tags: tags,
      );
      resources = [item, ...resources];
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createLink({
    required String title,
    required String subject,
    required String topic,
    required String url,
    required List<String> tags,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final item = await _repository.createLinkResource(
        title: title,
        subject: subject,
        topic: topic,
        url: url,
        tags: tags,
      );
      resources = [item, ...resources];
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Stream<List<CommentItem>> streamComments(String resourceId) => _repository.streamResourceComments(resourceId);

  Future<List<CommentItem>> fetchComments(String resourceId) => _repository.fetchResourceComments(resourceId);

  Future<void> addComment({
    required String resourceId,
    required String text,
  }) {
    return _repository.addComment(resourceId: resourceId, text: text);
  }
}
