import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/groups_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../../../shared/widgets/ui_helpers.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GroupsProvider>().load();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsProvider = context.watch<GroupsProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      body: AppScaffold(
        title: 'Study Groups',
        subtitle:
            'Real-time collaboration rooms for shared deadlines, resources, and accountability.',
        child: ListView(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Create a study room'),
                  TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.groups_outlined),
                          labelText: 'Group name')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.menu_book_outlined),
                          labelText: 'Subject')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _goalController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.flag_outlined),
                          labelText: 'Shared goal')),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: groupsProvider.loading
                        ? null
                        : () async {
                            await context.read<GroupsProvider>().createGroup(
                                  name: _nameController.text.trim(),
                                  subject: _subjectController.text.trim(),
                                  sharedGoal: _goalController.text.trim(),
                                );
                            _nameController.clear();
                            _subjectController.clear();
                            _goalController.clear();
                          },
                    icon: groupsProvider.loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add_rounded),
                    label: Text(groupsProvider.loading
                        ? 'Creating...'
                        : 'Create group'),
                  ),
                  if (groupsProvider.error != null) ...[
                    const SizedBox(height: 10),
                    ErrorText(groupsProvider.error!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Your study rooms'),
            if (groupsProvider.loading && groupsProvider.groups.isEmpty)
              const SkeletonScreen(cardCount: 3)
            else if (groupsProvider.groups.isEmpty)
              const GlassCard(
                child: EmptyState(
                  icon: Icons.groups_outlined,
                  title: 'No groups yet',
                  message:
                      'Create a room to test real-time shared tasks and comments.',
                ),
              )
            else
              ...groupsProvider.groups.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => GroupDetailScreen(group: group)),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(group.name,
                                    style: theme.textTheme.titleLarge)),
                            Chip(label: Text(group.subject)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(group.sharedGoal,
                            style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Text('Members: ${group.memberIds.length}'),
                        const SizedBox(height: 6),
                        Text(
                            'Invites pending: ${group.memberEmails.join(', ')}'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
