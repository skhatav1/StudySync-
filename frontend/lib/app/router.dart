import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/providers/auth_provider.dart';
import '../core/providers/profile_provider.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/assistant/presentation/screens/assistant_screen.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/groups/presentation/screens/group_detail_screen.dart';
import '../features/groups/presentation/screens/groups_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/resources/presentation/screens/resource_detail_screen.dart';
import '../features/resources/presentation/screens/resources_screen.dart';
import '../features/resources/presentation/screens/upload_resource_screen.dart';
import '../features/study_plan/presentation/screens/study_plan_screen.dart';
import '../features/study_plan/presentation/screens/study_session_detail_screen.dart';
import '../core/models/study_plan.dart';
import '../core/models/resource_models.dart' show ResourceItem;
import '../core/models/group_models.dart' show StudyGroup;
import 'home_shell_router.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(BuildContext context) {
  return GoRouter(
    navigatorKey: _rootKey,
    debugLogDiagnostics: false,
    redirect: (ctx, state) {
      final auth = ctx.read<AuthProvider>();
      final profile = ctx.read<ProfileProvider>();
      final loggedIn = auth.currentUser != null;
      final onAuth = state.matchedLocation == '/auth';

      if (!loggedIn) return onAuth ? null : '/auth';
      if (profile.loading || !profile.hasLoaded) return null;
      if (profile.needsOnboarding && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      if (!profile.needsOnboarding && onAuth) return '/';
      return null;
    },
    refreshListenable: _RouterListenable(context),
    routes: [
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (ctx, state, child) => HomeShellRouter(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/plan', builder: (_, __) => const StudyPlanScreen()),
          GoRoute(
            path: '/plan/session',
            builder: (ctx, state) {
              final task = state.extra as StudyTask;
              return StudySessionDetailScreen(task: task);
            },
          ),
          GoRoute(path: '/ai', builder: (_, __) => const AssistantScreen()),
          GoRoute(path: '/groups', builder: (_, __) => const GroupsScreen()),
          GoRoute(
            path: '/groups/detail',
            builder: (ctx, state) {
              final group = state.extra as StudyGroup;
              return GroupDetailScreen(group: group);
            },
          ),
          GoRoute(path: '/resources', builder: (_, __) => const ResourcesScreen()),
          GoRoute(path: '/resources/upload', builder: (_, __) => const UploadResourceScreen()),
          GoRoute(
            path: '/resources/detail',
            builder: (ctx, state) {
              final resource = state.extra as ResourceItem;
              return ResourceDetailScreen(resource: resource);
            },
          ),
          GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
        ],
      ),
    ],
  );
}

class _RouterListenable extends ChangeNotifier {
  _RouterListenable(BuildContext context) {
    context.read<AuthProvider>().addListener(notifyListeners);
    context.read<ProfileProvider>().addListener(notifyListeners);
  }
}
