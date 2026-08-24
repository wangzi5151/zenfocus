import 'package:flutter/material.dart';
import '../core/strings.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomeScreen(),
      HistoryScreen(),
      StatsScreen(),
      AchievementsScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: tr('专注', 'Focus'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: tr('记录', 'History'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: tr('统计', 'Stats'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: tr('成就', 'Awards'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune),
            selectedIcon: const Icon(Icons.tune),
            label: tr('设置', 'Settings'),
          ),
        ],
      ),
    );
  }
}
