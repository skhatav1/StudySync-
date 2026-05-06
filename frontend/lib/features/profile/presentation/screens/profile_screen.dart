import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/profile_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final theme = Theme.of(context);
    return Scaffold(
      body: AppScaffold(
        title: 'Profile & Preferences',
        subtitle: 'The AI planner adapts to learning style, weak areas, and available study hours.',
        child: ListView(
          children: [
            if (profile != null)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(profile.email),
                    const SizedBox(height: 14),
                    Text('Learning style: ${profile.learningStyle}'),
                    const SizedBox(height: 6),
                    Text('Available study time: ${profile.preferredStudyHours} hours/day'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.weakSubjects.map((area) => Chip(label: Text(area))).toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => context.read<AuthProvider>().signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
