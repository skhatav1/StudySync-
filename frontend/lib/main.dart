import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/studysync_app.dart';
import 'core/providers/demo_provider.dart';
import 'core/providers/analytics_provider.dart';
import 'core/providers/assistant_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/groups_provider.dart';
import 'core/providers/notifications_provider.dart';
import 'core/providers/plans_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/resources_provider.dart';
import 'core/providers/study_sessions_provider.dart';
import 'core/repositories/analytics_repository.dart';
import 'core/repositories/assistant_repository.dart';
import 'core/repositories/auth_repository.dart';
import 'core/repositories/demo_seed_repository.dart';
import 'core/repositories/groups_repository.dart';
import 'core/repositories/notifications_repository.dart';
import 'core/repositories/plans_repository.dart';
import 'core/repositories/profile_repository.dart';
import 'core/repositories/resources_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // runZonedGuarded must wrap everything so bindings are init'd in the same zone.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Catch Flutter framework errors — report to Crashlytics on mobile only.
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      };

      // Override the red error widget shown on widget build failures.
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return _AppErrorWidget(message: details.exception.toString());
      };

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepository(auth))),
            ChangeNotifierProvider(create: (_) => ProfileProvider(ProfileRepository())),
            ChangeNotifierProvider(create: (_) => PlansProvider(PlansRepository())),
            ChangeNotifierProvider(create: (_) => StudySessionsProvider(PlansRepository())),
            ChangeNotifierProvider(create: (_) => AssistantProvider(AssistantRepository())),
            ChangeNotifierProvider(create: (_) => AnalyticsProvider(AnalyticsRepository())),
            ChangeNotifierProvider(
              create: (_) => ResourcesProvider(ResourcesRepository(storage: storage, auth: auth)),
            ),
            ChangeNotifierProvider(
              create: (_) => GroupsProvider(GroupsRepository(firestore))..bind(),
            ),
            ChangeNotifierProvider(
              create: (_) => NotificationsProvider(
                  NotificationsRepository(firestore: firestore, auth: auth))
                ..bind(),
            ),
            ChangeNotifierProvider(
              create: (_) => DemoProvider(DemoSeedRepository(firestore: firestore, auth: auth)),
            ),
          ],
          child: const StudySyncApp(),
        ),
      );
    },
    (error, stack) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
    },
  );
}

class _AppErrorWidget extends StatelessWidget {
  const _AppErrorWidget({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => runApp(const SizedBox()),
                  child: const Text('Restart app'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
