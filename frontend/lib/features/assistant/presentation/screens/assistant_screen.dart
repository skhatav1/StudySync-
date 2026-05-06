import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/assistant_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';
import 'flashcards_result_screen.dart';
import 'quiz_result_screen.dart';
import 'summary_result_screen.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _subjectController = TextEditingController(text: 'Calculus');
  final _contentController = TextEditingController(
    text:
        'Integration by parts works well when one term gets simpler after differentiation and the other remains easy to integrate.',
  );

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<AssistantProvider>();
    final theme = Theme.of(context);
    final output = assistant.summary != null
        ? assistant.summary!.bullets.join('\n')
        : assistant.chatResponse?.reply ??
            (assistant.flashcards.isNotEmpty
                ? assistant.flashcards
                    .map((item) => '${item.question}: ${item.answer}')
                    .join('\n\n')
                : assistant.quiz.isNotEmpty
                    ? assistant.quiz.map((item) => item.question).join('\n')
                    : 'Ask StudySync AI to explain a concept, summarize notes, or generate practice material.');
    return Scaffold(
      body: AppScaffold(
        title: 'AI Study Assistant',
        subtitle:
            'Turn notes into summaries, quizzes, and flashcards without leaving the app.',
        child: ListView(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                      title: 'Prompt workspace',
                      subtitle: 'Paste notes or ask a study question.'),
                  TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.menu_book_outlined),
                          labelText: 'Subject')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.notes_outlined),
                        labelText: 'Paste study notes or ask a question'),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: assistant.loading
                            ? null
                            : () => context.read<AssistantProvider>().summarize(
                                  _subjectController.text.trim(),
                                  _contentController.text.trim(),
                                ),
                        icon: const Icon(Icons.summarize_outlined),
                        label: const Text('Summarize'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: assistant.loading
                            ? null
                            : () =>
                                context.read<AssistantProvider>().createQuiz(
                                      _subjectController.text.trim(),
                                      _contentController.text.trim(),
                                    ),
                        icon: const Icon(Icons.quiz_outlined),
                        label: const Text('Quiz'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: assistant.loading
                            ? null
                            : () => context
                                .read<AssistantProvider>()
                                .createFlashcards(
                                  _subjectController.text.trim(),
                                  _contentController.text.trim(),
                                ),
                        icon: const Icon(Icons.style_outlined),
                        label: const Text('Flashcards'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: assistant.loading
                            ? null
                            : () => context.read<AssistantProvider>().chat(
                                  _contentController.text.trim(),
                                  subject: _subjectController.text.trim(),
                                ),
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('Ask assistant'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF5D8), Color(0xFFFFE4B7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Assistant output'),
                  if (assistant.loading) const LinearProgressIndicator(),
                  if (assistant.error != null) ...[
                    ErrorText(assistant.error!),
                    const SizedBox(height: 12),
                  ],
                  Text(output,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
                  if (assistant.summary != null) ...[
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 14),
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
          ],
        ),
      ),
    );
  }
}
