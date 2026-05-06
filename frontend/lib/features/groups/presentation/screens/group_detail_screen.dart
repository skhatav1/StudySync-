import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/group_models.dart';
import '../../../../core/providers/groups_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.group});

  final StudyGroup group;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _taskController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = context.read<GroupsProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      body: AppScaffold(
        title: widget.group.name,
        subtitle:
            'Shared board detail for collaborative revision and live task coordination.',
        child: ListView(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.group.subject, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(widget.group.sharedGoal),
                  const SizedBox(height: 12),
                  Text('Members: ${widget.group.memberIds.join(', ')}'),
                  const SizedBox(height: 8),
                  Text('Invites: ${widget.group.memberEmails.join(', ')}'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                      title: 'Shared task board',
                      subtitle: 'Tasks update live for group members.'),
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.task_alt_rounded),
                        labelText: 'Add a collaborative task'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      if (_taskController.text.trim().isEmpty) return;
                      final dueDate = DateFormat('yyyy-MM-dd')
                          .format(DateTime.now().add(const Duration(days: 1)));
                      await groups.createTask(
                        groupId: widget.group.id,
                        title: _taskController.text.trim(),
                        dueDate: dueDate,
                      );
                      _taskController.clear();
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add task'),
                  ),
                  const SizedBox(height: 14),
                  StreamBuilder<List<GroupTask>>(
                    stream: groups.streamGroupTasks(widget.group.id),
                    builder: (context, snapshot) {
                      final tasks = snapshot.data ?? const <GroupTask>[];
                      if (tasks.isEmpty) {
                        return const EmptyState(
                          icon: Icons.task_alt_outlined,
                          title: 'No shared tasks yet',
                          message: 'Add a group task to test the live board.',
                        );
                      }
                      return Column(
                        children: tasks
                            .map(
                              (task) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Checkbox(
                                  value: task.completed,
                                  onChanged: (_) => groups.toggleTask(task),
                                ),
                                title: Text(task.title),
                                subtitle: Text('Due ${task.dueDate}'),
                                trailing: IconButton(
                                  onPressed: () => groups.deleteTask(task.id),
                                  icon:
                                      const Icon(Icons.delete_outline_rounded),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Live board comments'),
                  TextField(
                    controller: _commentController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.forum_outlined),
                        labelText: 'Leave a quick comment for the group'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      if (_commentController.text.trim().isEmpty) return;
                      await groups.addComment(
                        groupId: widget.group.id,
                        resourceId: 'group-board',
                        text: _commentController.text.trim(),
                      );
                      _commentController.clear();
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Post comment'),
                  ),
                  const SizedBox(height: 14),
                  StreamBuilder<List<CommentItem>>(
                    stream: groups.streamGroupComments(widget.group.id),
                    builder: (context, snapshot) {
                      final comments = snapshot.data ?? const <CommentItem>[];
                      if (comments.isEmpty) {
                        return const EmptyState(
                          icon: Icons.forum_outlined,
                          title: 'No comments yet',
                          message:
                              'Post a quick note to verify collaboration comments.',
                        );
                      }
                      return Column(
                        children: comments
                            .map(
                              (comment) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                    child: Icon(Icons.forum_rounded)),
                                title: Text(comment.text),
                                subtitle: Text(comment.createdAt),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
