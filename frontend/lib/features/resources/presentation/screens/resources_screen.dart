import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/resources_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';
import 'resource_detail_screen.dart';
import 'upload_resource_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final _subjectController = TextEditingController(text: 'Calculus');
  final _topicController = TextEditingController(text: 'Integration');
  final _tagsController = TextEditingController(text: 'exam, weak-area');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ResourcesProvider>().load();
      }
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resources = context.watch<ResourcesProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      body: AppScaffold(
        title: 'Resource Manager',
        subtitle:
            'Save study links, tag materials, and transform them into study assets with AI.',
        child: ListView(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Library filters',
                    subtitle:
                        'Use these fields as quick demo metadata for new resources.',
                    trailing: FilledButton.icon(
                      onPressed: resources.loading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const UploadResourceScreen()),
                              );
                            },
                      icon: const Icon(Icons.add_link_rounded),
                      label: const Text('Add'),
                    ),
                  ),
                  TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.menu_book_outlined),
                          labelText: 'Subject')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.topic_outlined),
                          labelText: 'Topic')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.sell_outlined),
                          labelText: 'Tags')),
                ],
              ),
            ),
            if (resources.error != null) ...[
              const SizedBox(height: 12),
              ErrorText(resources.error!),
            ],
            const SizedBox(height: 16),
            const SectionHeader(title: 'Saved resources'),
            if (resources.resources.isEmpty)
              const GlassCard(
                child: EmptyState(
                  icon: Icons.folder_open_rounded,
                  title: 'No resources yet',
                  message:
                      'Add a link or seed demo data to start generating summaries, flashcards, and quizzes.',
                ),
              )
            else
              ...resources.resources.map(
                (resource) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                ResourceDetailScreen(resource: resource)),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: resource.favorite
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          child: Icon(resource.favorite
                              ? Icons.star_rounded
                              : Icons.folder_rounded),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(resource.title,
                                  style: theme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                  '${resource.subject} • ${resource.topic} • ${resource.mimeType}'),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
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
