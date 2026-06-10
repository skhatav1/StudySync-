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
  final _formKey = GlobalKey<FormState>();

  // Profile fields
  final _nameController = TextEditingController(text: 'Alex Johnson');
  final _goalController = TextEditingController(text: 'Score above 90 in core subjects');
  final _hoursController = TextEditingController(text: '3.5');
  String _learningStyle = 'mixed';
  int _sessionLength = 50;
  final List<String> _studyTimes = ['18:00', '20:00'];

  // Courses (dynamic list)
  final List<_CourseEntry> _courses = [
    _CourseEntry(name: 'Calculus II', grade: 'B', confidence: 5),
    _CourseEntry(name: 'Biology', grade: 'B+', confidence: 6),
  ];

  // Exams & assignments
  final _examTitleController = TextEditingController(text: 'Calculus Midterm');
  final _examCourseController = TextEditingController(text: 'Calculus II');
  final _assignmentTitleController = TextEditingController(text: 'Biology lab report');
  final _assignmentCourseController = TextEditingController(text: 'Biology');
  final _weakSubjectsController = TextEditingController(text: 'Calculus, Biology');
  final _targetGradesController = TextEditingController(text: 'Calculus II:A, Biology:A-');

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _hoursController.dispose();
    _examTitleController.dispose();
    _examCourseController.dispose();
    _assignmentTitleController.dispose();
    _assignmentCourseController.dispose();
    _weakSubjectsController.dispose();
    _targetGradesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      body: AppScaffold(
        title: 'Set up your study engine',
        subtitle: 'This saves real profile, course, exam, and assignment data to Firestore.',
        child: Form(
          key: _formKey,
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
                    Text('Demo-ready defaults',
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF172033), fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(
                      'Edit these fields to match your real courses, or keep defaults for a quick demo.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: const Color(0xFF5F6B7A), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Profile basics ──────────────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Profile basics'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline_rounded), labelText: 'Full name'),
                      validator: (v) =>
                          v != null && v.trim().isNotEmpty ? null : 'Name is required',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _goalController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.flag_outlined), labelText: 'Academic goal'),
                      validator: (v) =>
                          v != null && v.trim().isNotEmpty ? null : 'Enter at least one goal',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _hoursController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.schedule_rounded),
                          labelText: 'Study hours per day'),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0 || n > 16) {
                          return 'Enter a number between 0.5 and 16';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Study preferences ───────────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Study preferences'),
                    DropdownButtonFormField<String>(
                      initialValue: _learningStyle,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.psychology_alt_outlined),
                          labelText: 'Learning style'),
                      items: const [
                        DropdownMenuItem(value: 'visual', child: Text('Visual')),
                        DropdownMenuItem(value: 'auditory', child: Text('Auditory')),
                        DropdownMenuItem(value: 'reading', child: Text('Reading / Writing')),
                        DropdownMenuItem(value: 'kinesthetic', child: Text('Kinesthetic')),
                        DropdownMenuItem(value: 'mixed', child: Text('Mixed')),
                      ],
                      onChanged: (v) => setState(() => _learningStyle = v ?? 'mixed'),
                    ),
                    const SizedBox(height: 12),
                    Text('Session length: $_sessionLength min',
                        style: theme.textTheme.bodyMedium),
                    Slider(
                      value: _sessionLength.toDouble(),
                      min: 20,
                      max: 90,
                      divisions: 7,
                      label: '$_sessionLength min',
                      onChanged: (v) => setState(() => _sessionLength = v.round()),
                    ),
                    const SizedBox(height: 4),
                    Text('Preferred study times',
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final time in ['08:00', '12:00', '14:00', '16:00', '18:00', '20:00', '22:00'])
                          FilterChip(
                            label: Text(time),
                            selected: _studyTimes.contains(time),
                            onSelected: (selected) => setState(() {
                              selected ? _studyTimes.add(time) : _studyTimes.remove(time);
                            }),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Courses ─────────────────────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Courses',
                      trailing: TextButton.icon(
                        onPressed: () => setState(() =>
                            _courses.add(_CourseEntry(name: '', grade: 'B', confidence: 5))),
                        icon: const Icon(Icons.add),
                        label: const Text('Add course'),
                      ),
                    ),
                    for (int i = 0; i < _courses.length; i++) ...[
                      _CourseRow(
                        entry: _courses[i],
                        onRemove: _courses.length > 1
                            ? () => setState(() => _courses.removeAt(i))
                            : null,
                      ),
                      if (i < _courses.length - 1) const Divider(height: 20),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Exams & assignments ─────────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Upcoming exam'),
                    TextFormField(
                      controller: _examCourseController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.menu_book_outlined), labelText: 'Course name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _examTitleController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.event_available_outlined), labelText: 'Exam title'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Upcoming assignment'),
                    TextFormField(
                      controller: _assignmentCourseController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.menu_book_outlined), labelText: 'Course name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _assignmentTitleController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.assignment_outlined),
                          labelText: 'Assignment title'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Weak subjects & target grades ───────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Self-assessment'),
                    TextFormField(
                      controller: _weakSubjectsController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.trending_down_rounded),
                          labelText: 'Weak subjects (comma-separated)',
                          hintText: 'e.g. Calculus, Chemistry'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _targetGradesController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.grade_outlined),
                          labelText: 'Target grades (Course:Grade, …)',
                          hintText: 'e.g. Calculus II:A, Biology:A-'),
                    ),
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
                    AppBullet('Resource-to-summary, flashcard, and quiz generation.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: provider.loading ? null : _submit,
                icon: provider.loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.rocket_launch_outlined),
                label: const Text('Save and launch'),
              ),
              if (provider.error != null) ...[
                const SizedBox(height: 8),
                ErrorText(provider.error!),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_studyTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one preferred study time.')),
      );
      return;
    }

    final provider = context.read<ProfileProvider>();
    final baseProfile = provider.profile!;
    final now = DateTime.now();

    final weakSubjects = _weakSubjectsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final targets = <String, String>{};
    for (final pair in _targetGradesController.text.split(',')) {
      final parts = pair.split(':');
      if (parts.length == 2) targets[parts[0].trim()] = parts[1].trim();
    }

    await provider.saveOnboarding(
      updatedProfile: UserProfile(
        uid: baseProfile.uid,
        name: _nameController.text.trim(),
        email: baseProfile.email,
        academicGoals: [_goalController.text.trim()],
        preferredStudyHours: double.tryParse(_hoursController.text.trim()) ?? 3,
        learningStyle: _learningStyle,
        weakSubjects: weakSubjects,
        preferredSessionLength: _sessionLength,
        preferredStudyTimes: List<String>.from(_studyTimes..sort()),
        targetGrades: targets,
        collaborationPreferences: const ['group-revision', 'resource-sharing'],
      ),
      newCourses: _courses
          .where((c) => c.name.trim().isNotEmpty)
          .map((c) => CourseModel(
                name: c.name.trim(),
                currentGrade: c.grade,
                confidence: c.confidence,
              ))
          .toList(),
      newExams: [
        ExamModel(
          courseName: _examCourseController.text.trim(),
          title: _examTitleController.text.trim(),
          examDate: DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 5))),
          targetScore: '90',
        ),
      ],
      newAssignments: [
        AssignmentModel(
          courseName: _assignmentCourseController.text.trim(),
          title: _assignmentTitleController.text.trim(),
          dueDate: DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 3))),
          estimatedHours: 4,
          priority: 'high',
        ),
      ],
    );
  }
}

class _CourseEntry {
  _CourseEntry({required this.name, required this.grade, required this.confidence});
  String name;
  String grade;
  int confidence;
}

class _CourseRow extends StatefulWidget {
  const _CourseRow({required this.entry, this.onRemove});
  final _CourseEntry entry;
  final VoidCallback? onRemove;

  @override
  State<_CourseRow> createState() => _CourseRowState();
}

class _CourseRowState extends State<_CourseRow> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.entry.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.menu_book_outlined), labelText: 'Course name'),
                onChanged: (v) => widget.entry.name = v,
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Course name required',
              ),
            ),
            if (widget.onRemove != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                tooltip: 'Remove course',
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: widget.entry.grade,
                decoration: const InputDecoration(labelText: 'Current grade'),
                items: ['A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'F']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => widget.entry.grade = v ?? 'B'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Confidence ${widget.entry.confidence}/10',
                      style: Theme.of(context).textTheme.bodySmall),
                  Slider(
                    value: widget.entry.confidence.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (v) => setState(() => widget.entry.confidence = v.round()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
