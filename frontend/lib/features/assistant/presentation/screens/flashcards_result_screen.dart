import 'package:flutter/material.dart';

import '../../../../core/models/ai_models.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';

class FlashcardsResultScreen extends StatelessWidget {
  const FlashcardsResultScreen({super.key, required this.flashcards});

  final List<FlashcardItem> flashcards;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: 'Flashcards',
        subtitle: 'Generated Q&A cards for fast recall and spaced repetition.',
        child: ListView(
          children: flashcards
              .map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.style_outlined),
                        const SizedBox(height: 10),
                        Text(card.question,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        AppBullet(card.answer),
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
