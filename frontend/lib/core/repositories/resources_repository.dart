import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/group_models.dart';
import '../models/resource_models.dart';
import '../services/api_client.dart';

class ResourcesRepository {
  ResourcesRepository({
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  })  : _storage = storage,
        _auth = auth;

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  Future<List<ResourceItem>> fetchResources() async {
    final response = await ApiClient.instance.client.get('/api/resources/');
    return (response.data as List<dynamic>? ?? const [])
        .map((item) => ResourceItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<ResourceItem> uploadResource({
    required PlatformFile file,
    required String subject,
    required String topic,
    required List<String> tags,
  }) async {
    final uid = _auth.currentUser!.uid;
    final bytes = file.bytes;
    if (bytes == null) {
      throw Exception('Select a file with in-memory bytes available.');
    }
    final path = 'resources/$uid/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: file.extension));
    final url = await ref.getDownloadURL();
    final response = await ApiClient.instance.client.post(
      '/api/resources/',
      data: {
        'title': file.name,
        'subject': subject,
        'topic': topic,
        'storage_path': path,
        'download_url': url,
        'mime_type': file.extension ?? 'application/octet-stream',
        'tags': tags,
        'favorite': false,
      },
    );
    return ResourceItem.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<ResourceItem> createLinkResource({
    required String title,
    required String subject,
    required String topic,
    required String url,
    required List<String> tags,
  }) async {
    final response = await ApiClient.instance.client.post(
      '/api/resources/',
      data: {
        'title': title,
        'subject': subject,
        'topic': topic,
        'storage_path': 'links/${DateTime.now().millisecondsSinceEpoch}',
        'download_url': url,
        'mime_type': 'text/link',
        'tags': tags,
        'favorite': false,
      },
    );
    return ResourceItem.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Stream<List<CommentItem>> streamResourceComments(String resourceId) {
    return Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => fetchResourceComments(resourceId))
        .asBroadcastStream();
  }

  Future<List<CommentItem>> fetchResourceComments(String resourceId) async {
    final response = await ApiClient.instance.client.get('/api/resources/$resourceId/comments');
    return (response.data as List<dynamic>? ?? const [])
        .map((item) => CommentItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> addComment({
    required String resourceId,
    required String text,
  }) async {
    await ApiClient.instance.client.post(
      '/api/resources/$resourceId/comments',
      data: {'text': text},
    );
  }
}
