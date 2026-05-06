class StudyGroup {
  const StudyGroup({
    required this.id,
    required this.name,
    required this.subject,
    required this.sharedGoal,
    required this.memberIds,
    required this.memberEmails,
  });

  final String id;
  final String name;
  final String subject;
  final String sharedGoal;
  final List<String> memberIds;
  final List<String> memberEmails;

  factory StudyGroup.fromJson(Map<String, dynamic> json) => StudyGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        subject: json['subject'] as String,
        sharedGoal: json['shared_goal'] as String,
        memberIds: List<String>.from(json['member_ids'] ?? const []),
        memberEmails: List<String>.from(json['member_emails'] ?? const []),
      );
}

class GroupTask {
  const GroupTask({
    required this.id,
    required this.groupId,
    required this.title,
    required this.dueDate,
    required this.assignedTo,
    required this.completed,
    required this.createdBy,
  });

  final String id;
  final String groupId;
  final String title;
  final String dueDate;
  final List<String> assignedTo;
  final bool completed;
  final String createdBy;

  factory GroupTask.fromJson(Map<String, dynamic> json) => GroupTask(
        id: json['id'] as String,
        groupId: json['group_id'] as String,
        title: json['title'] as String,
        dueDate: json['due_date'] as String,
        assignedTo: List<String>.from(json['assigned_to'] ?? const []),
        completed: json['completed'] as bool? ?? false,
        createdBy: json['created_by'] as String? ?? '',
      );
}

class CommentItem {
  const CommentItem({
    required this.id,
    required this.text,
    required this.authorId,
    required this.createdAt,
  });

  final String id;
  final String text;
  final String authorId;
  final String createdAt;

  factory CommentItem.fromJson(Map<String, dynamic> json) => CommentItem(
        id: json['id'] as String,
        text: json['text'] as String,
        authorId: json['author_id'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
      );
}
