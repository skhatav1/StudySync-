class ResourceItem {
  const ResourceItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.topic,
    required this.storagePath,
    required this.downloadUrl,
    required this.mimeType,
    required this.tags,
    required this.favorite,
  });

  final String id;
  final String title;
  final String subject;
  final String topic;
  final String storagePath;
  final String downloadUrl;
  final String mimeType;
  final List<String> tags;
  final bool favorite;

  factory ResourceItem.fromJson(Map<String, dynamic> json) => ResourceItem(
        id: json['id'] as String,
        title: json['title'] as String,
        subject: json['subject'] as String,
        topic: json['topic'] as String,
        storagePath: json['storage_path'] as String,
        downloadUrl: json['download_url'] as String,
        mimeType: json['mime_type'] as String,
        tags: List<String>.from(json['tags'] ?? const []),
        favorite: json['favorite'] as bool? ?? false,
      );
}
