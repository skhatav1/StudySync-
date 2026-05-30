import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/study_entities.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/providers/profile_provider.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController(text: 'Alex Johnson');
  final _goalController =
      TextEditingController(text: 'Score above 90 in core subjects');
  final _hoursController = TextEditingController(text: '3.5');
  final _courseController = TextEditingController(text: 'Calculus II');
  final _examController = TextEditingController(text: 'Calculus Midterm');
  final _assignmentController =
      TextEditingController(text: 'Biology lab report');
  final _weakSubjectsController =
      TextEditingController(text: 'Calculus, Biology');
  final _targetGradesController =
      TextEditingController(text: 'Calculus II:A, Biology:A-');

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _hoursController.dispose();
    _courseController.dispose();
    _examController.dispose();
    _assignmentController.dispose();
    _weakSubjectsController.dispose();
    _targetGradesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProfileProvider>();
    final baseProfile = provider.profile!;
    return Scaffold(
      body: AppScaffold(
        title: 'Set up your study engine',
        subtitle:
            'This saves real profile, course, exam, and assignment data to Firestore.',
        child: ListView(
          children: [
            GlassCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo-ready defaults',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF172033),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You can keep these values for a fast demo or edit them to match your own courses.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5F6B7A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Profile basics'),
                  TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline_rounded),
                          labelText: 'Full name')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _goalController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.flag_outlined),
                          labelText: 'Academic goal')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _hoursController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.schedule_rounded),
                        labelText: 'Study hours per day'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Study context'),
                  TextField(
                      controller: _courseController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.menu_book_outlined),
                          labelText: 'Primary course')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _examController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.event_available_outlined),
                          labelText: 'Upcoming exam title')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _assignmentController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.assignment_outlined),
                          labelText: 'Upcoming assignment title')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _weakSubjectsController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.trending_down_rounded),
                          labelText: 'Weak subjects')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _targetGradesController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.grade_outlined),
                          labelText: 'Target grades')),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: 'What this unlocks'),
                  AppBullet('Adaptive schedules that rebalance missed work.'),
                  AppBullet('Real-time study rooms and shared task boards.'),
                  AppBullet(
                      'Resource-to-summary, flashcard, and quiz generation.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: provider.loading
                  ? null
                  : () async {
                      final weakSubjects = _weakSubjectsController.text
                          .split(',')
                          .map((item) => item.trim())
                          .where((item) => item.isNotEmpty)
                          .toList();
                      final targets = <String, String>{};
                      for (final pair
                          in _targetGradesController.text.split(',')) {
                        final pieces = pair.split(':');
                        if (pieces.length == 2) {
                          targets[pieces[0].trim()] = pieces[1].trim();
                        }
                      }
                      final now = DateTime.now();
                      await context.read<ProfileProvider>().saveOnboarding(
                        updatedProfile: UserProfile(
                          uid: baseProfile.uid,
                          name: _nameController.text.trim(),
                          email: baseProfile.email,
                          academicGoals: [_goalController.text.trim()],
                          preferredStudyHours:
                              double.tryParse(_hoursController.text.trim()) ??
                                  3,
                          learningStyle: 'mixed',
                          weakSubjects: weakSubjects,
                          preferredSessionLength: 50,
                          preferredStudyTimes: const ['18:00', '20:00'],
                          targetGrades: targets,
                          collaborationPreferences: const [
                            'group-revision',
                            'resource-sharing'
                          ],
                        ),
                        newCourses: [
                          CourseModel(
                              name: _courseController.text.trim(),
                              currentGrade: 'B',
                              confidence: 5),
                          const CourseModel(
                              name: 'Biology',
                              currentGrade: 'B+',
                              confidence: 6),
                        ],
                        newExams: [
                          ExamModel(
                            courseName: _courseController.text.trim(),
                            title: _examController.text.trim(),
                            examDate: DateFormat('yyyy-MM-dd')
                                .format(now.add(const Duration(days: 5))),
                            targetScore: '90',
                          ),
                        ],
                        newAssignments: [
                          AssignmentModel(
                            courseName: 'Biology',
                            title: _assignmentController.text.trim(),
                            dueDate: DateFormat('yyyy-MM-dd')
                                .format(now.add(const Duration(days: 3))),
                            estimatedHours: 4,
                            priority: 'high',
                          ),
                        ],
                      );
                    },
              icon: provider.loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.rocket_launch_outlined),
              label: const Text('Save onboarding'),
            ),
            if (provider.error != null) ...[
              const SizedBox(height: 8),
              ErrorText(provider.error!),
            ],
          ],
        ),
      ),
    );
  }
}
