import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/plans_provider.dart';
import '../../../../core/providers/profile_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../../../shared/widgets/ui_helpers.dart';
import 'study_session_detail_screen.dart';

class StudyPlanScreen extends StatelessWidget {
  const StudyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = context.watch<PlansProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final plan = plans.plan;
    final theme = Theme.of(context);
    return Scaffold(
      body: AppScaffold(
        title: 'Adaptive Study Plan',
        subtitle:
            'Generate a weekly roadmap, then show judges how the plan rebalances after a missed session.',
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: plans.loading || profileProvider.profile == null
                        ? null
                        : () => context.read<PlansProvider>().generate(
                              profile: profileProvider.profile!,
                              courses: profileProvider.courses,
                              exams: profileProvider.exams,
                              assignments: profileProvider.assignments,
                            ),
                    icon: plans.loading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Generate AI plan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: plans.loading ||
                            profileProvider.profile == null ||
                            plan == null
                        ? null
                        : () => context.read<PlansProvider>().recalculate(
                              profile: profileProvider.profile!,
                              courses: profileProvider.courses,
                              exams: profileProvider.exams,
                              assignments: profileProvider.assignments,
                              missedTaskIds: plan.dailyPlan
                                  .expand((day) => day.sessions.take(1))
                                  .map((task) => task.id)
                                  .toList(),
                              reason:
                                  'User missed one study block and requested a realistic rebalance.',
                            ),
                    icon: plans.loading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.sync_rounded),
                    label: const Text('Recalculate'),
                  ),
                ),
              ],
            ),
            if (plans.error != null) ...[
              const SizedBox(height: 12),
              ErrorText(plans.error!),
            ],
            const SizedBox(height: 16),
            if (plans.loading && plan == null)
              const SkeletonScreen(cardCount: 3)
            else if (plan == null)
              const GlassCard(
                child: EmptyState(
                  icon: Icons.event_note_outlined,
                  title: 'No plan generated yet',
                  message: 'Complete onboarding and tap Generate AI plan.',
                ),
              ),
            ...?plan?.dailyPlan.map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(day.date, style: theme.textTheme.titleLarge),
                          const Spacer(),
                          Chip(label: Text('${day.sessions.length} sessions')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(day.focusTheme, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 14),
                      ...day.sessions.map(
                        (session) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StudySessionDetailScreen(task: session),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(session.title,
                                      style: theme.textTheme.titleMedium),
                                  const SizedBox(height: 6),
                                  Text(
                                      '${session.courseName} • ${session.durationMinutes} min'),
                                  const SizedBox(height: 6),
                                  Text(session.rationale,
                                      style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
