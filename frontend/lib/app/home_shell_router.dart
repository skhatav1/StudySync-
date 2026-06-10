import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/providers/analytics_provider.dart';
import '../core/providers/groups_provider.dart';
import '../core/providers/plans_provider.dart';
import '../core/providers/resources_provider.dart';
import '../core/providers/study_sessions_provider.dart';

class HomeShellRouter extends StatefulWidget {
  const HomeShellRouter({super.key, required this.child});
  final Widget child;

  @override
  State<HomeShellRouter> createState() => _HomeShellRouterState();
}

class _HomeShellRouterState extends State<HomeShellRouter> {
  static const _tabs = ['/', '/plan', '/ai', '/groups', '/resources', '/analytics', '/profile'];

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

  int _tabIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _tabIndex(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (i) => context.go(_tabs[i]),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 12),
                    child: Icon(Icons.school_rounded),
                  ),
                  destinations: _railDestinations,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: widget.child),
              ],
            ),
          );
        }
        return Scaffold(
          body: widget.child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => context.go(_tabs[i]),
            destinations: _barDestinations,
          ),
        );
      },
    );
  }

  static const _railDestinations = [
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
  ];

  static const _barDestinations = [
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
  ];
}
