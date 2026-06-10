import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/analytics_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<AnalyticsProvider>().summary;
    return Scaffold(
      body: AppScaffold(
        title: 'Progress Analytics',
        subtitle:
            'Visually strong stats for streaks, workload balance, and weak-area recovery.',
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                    child: _MetricCard(
                        title: 'Study streak',
                        value: '${summary?.streakDays ?? 0}',
                        label: 'days')),
                const SizedBox(width: 12),
                Expanded(
                    child: _MetricCard(
                        title: 'Hours',
                        value: '${summary?.hoursStudied ?? 0}',
                        label: 'this week')),
              ],
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                      title: 'Weekly intensity',
                      subtitle: 'Demo chart showing study-hour distribution.'),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const labels = [
                                  'M',
                                  'T',
                                  'W',
                                  'T',
                                  'F',
                                  'S',
                                  'S'
                                ];
                                return Text(labels[value.toInt()]);
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(7, (i) {
                          final hours = summary?.weeklyHours.elementAtOrNull(i) ?? 0.0;
                          return BarChartGroupData(
                            x: i,
                            barRods: [BarChartRodData(toY: hours, width: 16)],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'AI insights'),
                  Chip(
                    avatar: const Icon(Icons.speed_rounded, size: 16),
                    label: Text(
                        'Productivity score ${summary?.productivityScore ?? 0}/100'),
                  ),
                  const SizedBox(height: 12),
                  if ((summary?.aiInsights ?? const <String>[]).isEmpty)
                    const EmptyState(
                      icon: Icons.insights_outlined,
                      title: 'No insights yet',
                      message:
                          'Generate a plan and complete sessions to populate analytics.',
                    )
                  else
                    ...summary!.aiInsights.map((item) => AppBullet(item)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.title, required this.value, required this.label});

  final String title;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineSmall,
              children: [
                TextSpan(text: value),
                TextSpan(text: ' $label', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
