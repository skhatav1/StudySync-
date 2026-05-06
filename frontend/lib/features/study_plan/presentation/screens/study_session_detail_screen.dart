import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/study_plan.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/providers/plans_provider.dart';
import '../../../../core/providers/study_sessions_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';

class StudySessionDetailScreen extends StatefulWidget {
  const StudySessionDetailScreen({super.key, required this.task});

  final StudyTask task;

  @override
  State<StudySessionDetailScreen> createState() => _StudySessionDetailScreenState();
}

class _StudySessionDetailScreenState extends State<StudySessionDetailScreen> {
  final _minutesController = TextEditingController();
  final _reflectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _minutesController.text = widget.task.durationMinutes.toString();
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final sessions = context.watch<StudySessionsProvider>();
    final active = sessions.sessions.where((session) => session.taskId == task.id).toList();
    final latest = active.isNotEmpty ? active.first : null;
    final start = DateTime.tryParse(task.scheduledStart);
    final end = DateTime.tryParse(task.scheduledEnd);
    return Scaffold(
      body: AppScaffold(
        title: task.title,
        subtitle: 'Session detail view for demoing concrete plan execution.',
        child: ListView(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.courseName, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text('Priority: ${task.priority}'),
                  const SizedBox(height: 6),
                  Text('Duration: ${task.durationMinutes} minutes'),
                  const SizedBox(height: 6),
                  Text(
                    'Time: ${start != null ? DateFormat.yMMMd().add_jm().format(start) : task.scheduledStart} - ${end != null ? DateFormat.jm().format(end) : task.scheduledEnd}',
                  ),
                  const SizedBox(height: 14),
                  Text(task.rationale),
                  if (latest != null) ...[
                    const SizedBox(height: 14),
                    Text('Latest log: ${latest.completed ? 'Completed' : 'In progress'}'),
                    const SizedBox(height: 6),
                    Text('Started at ${latest.startedAt}'),
                    if (latest.completed) Text('Actual minutes: ${latest.actualMinutes}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Study timer + completion', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (sessions.error != null) ...[
                    Text(sessions.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 12),
                  ],
                  if (latest == null || latest.completed)
                    FilledButton(
                      onPressed: sessions.loading
                          ? null
                          : () async {
                              await context.read<StudySessionsProvider>().start(task);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Study session started.')),
                                );
                              }
                            },
                      child: const Text('Start session'),
                    )
                  else ...[
                    TextField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Actual minutes studied'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reflectionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Reflection or blockers'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: sessions.loading
                          ? null
                          : () async {
                              final sessionsProvider = context.read<StudySessionsProvider>();
                              final plansProvider = context.read<PlansProvider>();
                              final analyticsProvider = context.read<AnalyticsProvider>();
                              await sessionsProvider.complete(
                                    sessionId: latest.id,
                                    actualMinutes: int.tryParse(_minutesController.text.trim()) ?? task.durationMinutes,
                                    reflection: _reflectionController.text.trim().isEmpty ? null : _reflectionController.text.trim(),
                                  );
                              if (!context.mounted) return;
                              await plansProvider.load();
                              await analyticsProvider.load();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Session completed and analytics refreshed.')),
                              );
                            },
                      child: const Text('Complete session'),
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
