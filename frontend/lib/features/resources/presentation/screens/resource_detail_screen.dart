import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/group_models.dart';
import '../../../../core/models/resource_models.dart';
import '../../../../core/providers/assistant_provider.dart';
import '../../../../core/providers/resources_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';
import '../../../assistant/presentation/screens/flashcards_result_screen.dart';
import '../../../assistant/presentation/screens/quiz_result_screen.dart';
import '../../../assistant/presentation/screens/summary_result_screen.dart';

class ResourceDetailScreen extends StatefulWidget {
  const ResourceDetailScreen({super.key, required this.resource});

  final ResourceItem resource;

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resources = context.read<ResourcesProvider>();
    final assistant = context.watch<AssistantProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      body: AppScaffold(
        title: widget.resource.title,
        subtitle:
            'Resource detail for tags, linked topic, and AI follow-up actions.',
        child: ListView(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.resource.subject} • ${widget.resource.topic}',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text('Type: ${widget.resource.mimeType}'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.resource.tags
                        .map((tag) => Chip(label: Text(tag)))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  SelectableText(widget.resource.downloadUrl),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                      title: 'AI actions',
                      subtitle:
                          'Generate structured study assets from this resource.'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: assistant.loading
                            ? null
                            : () => context.read<AssistantProvider>().summarize(
                                  widget.resource.subject,
                                  'Summarize the core ideas from ${widget.resource.title} about ${widget.resource.topic}.',
                                ),
                        icon: const Icon(Icons.summarize_outlined),
                        label: const Text('Summarize'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: assistant.loading
                            ? null
                            : () => context
                                .read<AssistantProvider>()
                                .createFlashcards(
                                  widget.resource.subject,
                                  'Generate flashcards from ${widget.resource.title} about ${widget.resource.topic}.',
                                ),
                        icon: const Icon(Icons.style_outlined),
                        label: const Text('Flashcards'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: assistant.loading
                            ? null
                            : () =>
                                context.read<AssistantProvider>().createQuiz(
                                      widget.resource.subject,
                                      'Generate a quiz from ${widget.resource.title} about ${widget.resource.topic}.',
                                    ),
                        icon: const Icon(Icons.quiz_outlined),
                        label: const Text('Quiz'),
                      ),
                    ],
                  ),
                  if (assistant.loading) ...[
                    const SizedBox(height: 14),
                    const LinearProgressIndicator(),
                  ],
                  if (assistant.error != null) ...[
                    const SizedBox(height: 12),
                    ErrorText(assistant.error!),
                  ],
                  if (assistant.summary != null) ...[
                    const SizedBox(height: 12),
                    Text(assistant.summary!.bullets.join('\n')),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SummaryResultScreen(
                                summary: assistant.summary!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open summary'),
                    ),
                  ],
                  if (assistant.flashcards.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                        '${assistant.flashcards.length} flashcards generated.'),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FlashcardsResultScreen(
                                flashcards: assistant.flashcards),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open flashcards'),
                    ),
                  ],
                  if (assistant.quiz.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('${assistant.quiz.length} quiz questions generated.'),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                QuizResultScreen(questions: assistant.quiz),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open quiz'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                      title: 'Comments',
                      subtitle: 'Quick notes for shared study resources.'),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.comment_outlined),
                        labelText: 'Add a comment on this resource'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      if (_commentController.text.trim().isEmpty) return;
                      await resources.addComment(
                        resourceId: widget.resource.id,
                        text: _commentController.text.trim(),
                      );
                      _commentController.clear();
                      if (context.mounted) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Post comment'),
                  ),
                  const SizedBox(height: 14),
                  StreamBuilder<List<CommentItem>>(
                    stream: resources.streamComments(widget.resource.id),
                    builder: (context, snapshot) {
                      final comments = snapshot.data ?? const <CommentItem>[];
                      if (comments.isEmpty) {
                        return const EmptyState(
                          icon: Icons.forum_outlined,
                          title: 'No comments yet',
                          message:
                              'Post a quick note to test collaboration comments.',
                        );
                      }
                      return Column(
                        children: comments
                            .map<Widget>(
                              (comment) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                    child: Icon(Icons.comment_rounded)),
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
