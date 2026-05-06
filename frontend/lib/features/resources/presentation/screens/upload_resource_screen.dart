import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/resources_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';

class UploadResourceScreen extends StatefulWidget {
  const UploadResourceScreen({super.key});

  @override
  State<UploadResourceScreen> createState() => _UploadResourceScreenState();
}

class _UploadResourceScreenState extends State<UploadResourceScreen> {
  final _titleController =
      TextEditingController(text: 'Integration Techniques Notes');
  final _subjectController = TextEditingController(text: 'Calculus');
  final _topicController = TextEditingController(text: 'Integration');
  final _urlController =
      TextEditingController(text: 'https://example.com/integration-notes');
  final _tagsController = TextEditingController(text: 'exam, weak-area');

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _topicController.dispose();
    _urlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resources = context.watch<ResourcesProvider>();
    return Scaffold(
      body: AppScaffold(
        title: 'Add Resource',
        subtitle:
            'Save a study link or reference so AI can transform it into review material.',
        child: ListView(
          children: [
            GlassCard(
              child: Column(
                children: [
                  TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.title_rounded),
                          labelText: 'Title')),
                  const SizedBox(height: 12),
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
                      controller: _urlController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.link_rounded),
                          labelText: 'Link or reference URL')),
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
            FilledButton.icon(
              onPressed: resources.loading
                  ? null
                  : () async {
                      await context.read<ResourcesProvider>().createLink(
                            title: _titleController.text.trim(),
                            subject: _subjectController.text.trim(),
                            topic: _topicController.text.trim(),
                            url: _urlController.text.trim(),
                            tags: _tagsController.text
                                .split(',')
                                .map((item) => item.trim())
                                .where((item) => item.isNotEmpty)
                                .toList(),
                          );
                      if (context.mounted) Navigator.of(context).pop();
                    },
              icon: const Icon(Icons.link_rounded),
              label: Text(resources.loading ? 'Saving...' : 'Save resource'),
            ),
            const SizedBox(height: 12),
            const GlassCard(
              child: AppBullet(
                  'File uploads can be enabled later after Firebase Storage billing is available. Links work now on the Spark plan.'),
            ),
          ],
        ),
      ),
    );
  }
}
