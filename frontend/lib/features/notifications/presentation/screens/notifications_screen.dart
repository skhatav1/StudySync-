import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/notifications_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationsProvider>().notifications;
    return Scaffold(
      body: AppScaffold(
        title: 'Notifications',
        subtitle: 'Live product updates for plan changes, group activity, and study reminders.',
        child: ListView(
          children: notifications.isEmpty
              ? const [GlassCard(child: Text('No notifications yet. Seed the demo workspace to populate this screen.'))]
              : notifications
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(item.body),
                            const SizedBox(height: 8),
                            Text(item.createdAt),
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
