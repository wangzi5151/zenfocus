import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/strings.dart';
import 'services/notification_service.dart';
import 'services/settings_provider.dart';
import 'services/stats_store.dart';
import 'services/timer_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsProvider();
  await settings.load();

  final stats = StatsStore();
  await stats.load();

  final engine = TimerEngine(settings, stats);

  S.init(settings.langPref, WidgetsBinding.instance.platformDispatcher.locale);

  await NotificationService.instance.init();

  runApp(
    ZenFocusApp(settings: settings, stats: stats, engine: engine),
  );
}
