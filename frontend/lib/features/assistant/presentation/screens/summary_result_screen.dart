import 'package:flutter/material.dart';

import '../../../../core/models/ai_models.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';

class SummaryResultScreen extends StatelessWidget {
  const SummaryResultScreen({super.key, required this.summary});

  final SummaryResult summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: summary.title,
        subtitle:
            'AI-generated summary for quick review and presentation demos.',
        child: ListView(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Key bullets'),
                  ...summary.bullets.map(AppBullet.new),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Takeaways'),
                  ...summary.keyTakeaways.map(AppBullet.new),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
