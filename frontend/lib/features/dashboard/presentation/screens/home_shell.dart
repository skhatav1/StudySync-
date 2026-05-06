import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/providers/groups_provider.dart';
import '../../../../core/providers/plans_provider.dart';
import '../../../../core/providers/resources_provider.dart';
import '../../../../core/providers/study_sessions_provider.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../assistant/presentation/screens/assistant_screen.dart';
import '../../../groups/presentation/screens/groups_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../resources/presentation/screens/resources_screen.dart';
import '../../../study_plan/presentation/screens/study_plan_screen.dart';
import 'dashboard_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlansProvider>().load();
      context.read<StudySessionsProvider>().load();
      context.read<AnalyticsProvider>().load();
      context.read<ResourcesProvider>().load();
      context.read<GroupsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    const screens = [
      DashboardScreen(),
      StudyPlanScreen(),
      AssistantScreen(),
      GroupsScreen(),
      ResourcesScreen(),
      AnalyticsScreen(),
      ProfileScreen(),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentTab,
                  onDestinationSelected: (index) =>
                      setState(() => currentTab = index),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 12),
                    child: Icon(Icons.school_rounded),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                        icon: Icon(Icons.dashboard_customize_outlined),
                        selectedIcon: Icon(Icons.dashboard_customize),
                        label: Text('Home')),
                    NavigationRailDestination(
                        icon: Icon(Icons.event_note_outlined),
                        selectedIcon: Icon(Icons.event_note),
                        label: Text('Plan')),
                    NavigationRailDestination(
                        icon: Icon(Icons.psychology_alt_outlined),
                        selectedIcon: Icon(Icons.psychology_alt),
                        label: Text('AI')),
                    NavigationRailDestination(
                        icon: Icon(Icons.groups_outlined),
                        selectedIcon: Icon(Icons.groups),
                        label: Text('Groups')),
                    NavigationRailDestination(
                        icon: Icon(Icons.folder_open_outlined),
                        selectedIcon: Icon(Icons.folder_open),
                        label: Text('Files')),
                    NavigationRailDestination(
                        icon: Icon(Icons.analytics_outlined),
                        selectedIcon: Icon(Icons.analytics),
                        label: Text('Stats')),
                    NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Profile')),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: screens[currentTab]),
              ],
            ),
          );
        }
        return Scaffold(
          body: screens[currentTab],
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentTab,
            onDestinationSelected: (index) =>
                setState(() => currentTab = index),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.dashboard_customize_outlined),
                  selectedIcon: Icon(Icons.dashboard_customize),
                  label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.event_note_outlined),
                  selectedIcon: Icon(Icons.event_note),
                  label: 'Plan'),
              NavigationDestination(
                  icon: Icon(Icons.psychology_alt_outlined),
                  selectedIcon: Icon(Icons.psychology_alt),
                  label: 'AI'),
              NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups),
                  label: 'Groups'),
              NavigationDestination(
                  icon: Icon(Icons.folder_open_outlined),
                  selectedIcon: Icon(Icons.folder_open),
                  label: 'Files'),
              NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: 'Stats'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
