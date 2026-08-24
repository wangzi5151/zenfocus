import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'services/settings_provider.dart';
import 'services/stats_store.dart';
import 'services/timer_engine.dart';
import 'ui/root_shell.dart';
import 'ui/screens/onboarding_screen.dart';

class ZenFocusApp extends StatelessWidget {
  const ZenFocusApp({
    super.key,
    required this.settings,
    required this.stats,
    required this.engine,
  });

  final SettingsProvider settings;
  final StatsStore stats;
  final TimerEngine engine;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider<StatsStore>.value(value: stats),
        ChangeNotifierProvider<TimerEngine>.value(value: engine),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'ZenFocus',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: settings.themeMode,
            home: settings.onboarded
                ? const RootShell()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
