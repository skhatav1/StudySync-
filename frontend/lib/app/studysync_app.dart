import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/auth_provider.dart';
import '../core/providers/profile_provider.dart';
import '../core/theme/studysync_theme.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/dashboard/presentation/screens/home_shell.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';

class StudySyncApp extends StatelessWidget {
  const StudySyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();

    final currentUser = auth.currentUser;
    if (currentUser == null && profile.hasLoaded) {
      profile.clear();
    }
    if (currentUser != null &&
        profile.loadedUid != currentUser.uid &&
        !profile.loading) {
      profile.seedDemoFields(currentUser);
      profile.load(currentUser);
    }

    return MaterialApp(
      title: 'StudySync',
      debugShowCheckedModeBanner: false,
      theme: StudySyncTheme.light(),
      darkTheme: StudySyncTheme.dark(),
      themeMode: ThemeMode.system,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _buildHome(auth, profile),
      ),
    );
  }

  Widget _buildHome(AuthProvider auth, ProfileProvider profile) {
    if (auth.currentUser == null) {
      return const AuthScreen();
    }
    if (profile.loading || !profile.hasLoaded || profile.profile == null) {
      return const _SplashScreen();
    }
    if (profile.needsOnboarding) {
      return const OnboardingScreen();
    }
    return const HomeShell();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF123458), Color(0xFF1F6E8C), Color(0xFFDDF2FD)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              Text('StudySync', style: theme.textTheme.displaySmall?.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                'Adaptive planning for ambitious students.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
