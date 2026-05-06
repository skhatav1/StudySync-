import 'package:flutter/material.dart';

import '../../../../core/models/ai_models.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.questions});

  final List<QuizQuestionModel> questions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: 'Quiz Preview',
        subtitle: 'Generated practice questions ready for a quick demo run.',
        child: ListView(
          children: questions
              .map(
                (question) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.quiz_outlined),
                        const SizedBox(height: 10),
                        Text(question.question,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        ...question.options.map(AppBullet.new),
                        const SizedBox(height: 10),
                        Chip(label: Text('Answer: ${question.answer}')),
                        const SizedBox(height: 6),
                        Text(question.explanation),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
