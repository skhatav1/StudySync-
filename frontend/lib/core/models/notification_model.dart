class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.read,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final String createdAt;
  final bool read;

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: json['type'] as String? ?? 'info',
        createdAt: json['created_at'] as String? ?? '',
        read: json['read'] as bool? ?? false,
      );
}
