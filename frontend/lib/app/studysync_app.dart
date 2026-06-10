import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/auth_provider.dart';
import '../core/providers/profile_provider.dart';
import '../core/theme/studysync_theme.dart';
import 'router.dart';

class StudySyncApp extends StatefulWidget {
  const StudySyncApp({super.key});

  @override
  State<StudySyncApp> createState() => _StudySyncAppState();
}

class _StudySyncAppState extends State<StudySyncApp> {
  late final _router = buildRouter(context);

  @override
  void initState() {
    super.initState();
    // Seed profile shell and load as soon as auth state is available.
    context.read<AuthProvider>().addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final user = auth.currentUser;
    if (user == null) {
      profile.clear();
    } else if (profile.loadedUid != user.uid && !profile.loading) {
      profile.seedDemoFields(user);
      profile.load(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth/profile so the router redirect fires on changes.
    context.watch<AuthProvider>();
    context.watch<ProfileProvider>();

    return MaterialApp.router(
      title: 'StudySync',
      debugShowCheckedModeBanner: false,
      theme: StudySyncTheme.light(),
      darkTheme: StudySyncTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
