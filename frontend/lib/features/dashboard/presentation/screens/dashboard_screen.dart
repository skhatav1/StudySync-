import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/providers/demo_provider.dart';
import '../../../../core/providers/groups_provider.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../../../core/providers/plans_provider.dart';
import '../../../../core/providers/profile_provider.dart';
import '../../../../core/providers/resources_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final analytics = context.watch<AnalyticsProvider>().summary;
    final plan = context.watch<PlansProvider>().plan;
    final demo = context.watch<DemoProvider>();
    final notifications = context.watch<NotificationsProvider>().notifications;
    final theme = Theme.of(context);
    final recommendation = plan?.recommendations.isNotEmpty == true
        ? plan!.recommendations.first.reason
        : 'Generate your first AI plan to get deadline-aware recommendations.';
    return Scaffold(
      body: AppScaffold(
        title: 'Welcome back, ${profile?.name.split(' ').first ?? 'Student'}',
        subtitle:
            'Your AI planner is balancing deadlines, weak areas, and collaboration opportunities.',
        trailing: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          icon: Badge(
            label: Text('${notifications.length}'),
            isLabelVisible: notifications.isNotEmpty,
            child: const Icon(Icons.notifications_none_rounded),
          ),
        ),
        child: ListView(
          children: [
            GlassCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F6E8C), Color(0xFF2D5BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Today’s AI recommendation',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(recommendation,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: Colors.white70, height: 1.45)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _StatChip(
                          label: 'Streak',
                          value: '${analytics?.streakDays ?? 0} days'),
                      const SizedBox(width: 10),
                      _StatChip(
                          label: 'Hours',
                          value: '${analytics?.hoursStudied ?? 0}h'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  _MiniCard(
                    icon: Icons.event_available_outlined,
                    title: 'Upcoming',
                    value:
                        '${analytics?.upcomingDeadlines.length ?? 0} deadlines',
                    caption: (analytics != null &&
                            analytics.upcomingDeadlines.isNotEmpty)
                        ? analytics.upcomingDeadlines.first
                        : 'Sync exams and assignments in onboarding.',
                  ),
                  _MiniCard(
                    icon: Icons.trending_down_rounded,
                    title: 'Weak areas',
                    value: '${analytics?.weakSubjects.length ?? 0} detected',
                    caption: analytics?.weakSubjects.join(', ') ??
                        'No weak areas flagged yet.',
                  ),
                ];
                if (constraints.maxWidth < 620) {
                  return Column(
                    children: [
                      cards.first,
                      const SizedBox(height: 12),
                      cards.last,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: cards.first),
                    const SizedBox(width: 12),
                    Expanded(child: cards.last),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Demo workspace',
                    subtitle:
                        'Seed groups, notifications, a sample resource, and a generated study plan.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: demo.loading || profile == null
                        ? null
                        : () async {
                            await context.read<DemoProvider>().seedWorkspace(
                                  profile: profile,
                                  courses:
                                      context.read<ProfileProvider>().courses,
                                  exams: context.read<ProfileProvider>().exams,
                                  assignments: context
                                      .read<ProfileProvider>()
                                      .assignments,
                                );
                            if (context.mounted) {
                              context.read<PlansProvider>().load();
                              context.read<AnalyticsProvider>().load();
                              context.read<ResourcesProvider>().load();
                              context.read<GroupsProvider>().load();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Demo workspace seeded.')),
                              );
                            }
                          },
                    icon: const Icon(Icons.bolt_rounded),
                    label: demo.loading
                        ? const Text('Seeding...')
                        : const Text('Load demo data'),
                  ),
                  if (demo.error != null) ...[
                    const SizedBox(height: 8),
                    ErrorText(demo.error!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'This week’s subjects'),
                  if (context.watch<ProfileProvider>().courses.isEmpty)
                    const EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'No courses yet',
                      message:
                          'Complete onboarding or load demo data to populate subjects.',
                    )
                  else
                    ...context.watch<ProfileProvider>().courses.map(
                          (course) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(course.name,
                                        style: theme.textTheme.titleMedium)),
                                Text('Confidence ${course.confidence}/10',
                                    style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'AI insights'),
                  ...((analytics?.aiInsights ?? const <String>[]).isEmpty
                          ? const [
                              'Your analytics insights will appear after you generate a plan and complete sessions.'
                            ]
                          : analytics!.aiInsights)
                      .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: const Icon(Icons.auto_awesome_rounded),
                        ),
                        title: Text(item),
                        subtitle: const Text(
                            'Generated from your current workload, completion rate, and deadlines.'),
                      ),
                    ),
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

class _MiniCard extends StatelessWidget {
  const _MiniCard(
      {required this.icon,
      required this.title,
      required this.value,
      required this.caption});

  final IconData icon;
  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(caption, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
