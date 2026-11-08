import 'package:flutter_test/flutter_test.dart';
import 'package:zenfocus/services/settings_provider.dart';
import 'package:zenfocus/services/stats_store.dart';
import 'package:zenfocus/services/timer_engine.dart';

class _MemoryTimerStateStore extends TimerStateStore {
  Map<String, dynamic>? state;

  @override
  Future<Map<String, dynamic>?> load() async => state;

  @override
  Future<void> save(Map<String, dynamic>? value) async {
    state = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsProvider settings;
  late StatsStore stats;
  late DateTime clock;

  TimerEngine buildEngine({TimerStateStore? store}) => TimerEngine(
        settings,
        stats,
        clock: () => clock,
        store: store,
        effectsEnabled: false,
      );

  setUp(() {
    settings = SettingsProvider();
    settings.focusMin = 25;
    settings.breakMin = 5;
    settings.longBreakMin = 15;
    settings.sessionsBeforeLongBreak = 4;
    settings.autoStart = false;
    stats = StatsStore();
    clock = DateTime(2026, 1, 1, 10);
  });

  void advance(Duration d) => clock = clock.add(d);

  group('TimerEngine', () {
    test('initial remaining reflects configured focus duration', () {
      settings.focusMin = 50;
      final engine = buildEngine();
      addTearDown(engine.dispose);

      expect(engine.remaining, 50 * 60);
      expect(engine.total, 50 * 60);
    });

    test('syncIdleDuration applies new settings while idle', () {
      final engine = buildEngine();
      addTearDown(engine.dispose);

      settings.breakMin = 12;
      engine.phase = Phase.rest;
      engine.syncIdleDuration();

      expect(engine.remaining, 12 * 60);
    });

    test('completes focus and transitions to short break', () {
      settings.focusMin = 1;
      settings.breakMin = 1;
      final engine = buildEngine();
      addTearDown(engine.dispose);

      engine.start();
      advance(const Duration(seconds: 60));
      engine.syncFromClock();

      expect(engine.running, isFalse);
      expect(engine.phase, Phase.rest);
      expect(engine.sessionCount, 1);
      expect(stats.totalSessions, 1);
      expect(stats.totalMinutes, 1);
      expect(engine.remaining, 60);
    });

    test('enters long break after configured number of focus sessions', () {
      settings.focusMin = 1;
      settings.breakMin = 1;
      settings.longBreakMin = 2;
      settings.sessionsBeforeLongBreak = 2;
      final engine = buildEngine();
      addTearDown(engine.dispose);

      engine.start();
      advance(const Duration(seconds: 60));
      engine.syncFromClock();
      expect(engine.phase, Phase.rest);

      engine.start();
      advance(const Duration(seconds: 60));
      engine.syncFromClock();
      expect(engine.phase, Phase.focus);

      engine.start();
      advance(const Duration(seconds: 60));
      engine.syncFromClock();
      expect(engine.phase, Phase.longRest);
      expect(engine.remaining, 120);
      expect(engine.sessionCount, 2);
    });

    test('recovers elapsed time from wall clock after backgrounding', () {
      final engine = buildEngine();
      addTearDown(engine.dispose);

      engine.start();
      advance(const Duration(seconds: 60));
      engine.syncFromClock();
      expect(engine.remaining, 25 * 60 - 60);

      advance(const Duration(minutes: 5));
      engine.pause();
      expect(engine.remaining, 25 * 60 - 360);
      expect(engine.running, isFalse);

      advance(const Duration(hours: 2));
      engine.syncFromClock();
      expect(engine.remaining, 25 * 60 - 360);
    });

    test('restores a running timer and completes it once after process death',
        () async {
      settings.focusMin = 1;
      final store = _MemoryTimerStateStore();
      final engine = buildEngine(store: store);
      engine.start();
      expect(store.state?['running'], isTrue);
      expect(store.state?['endAt'], isNotNull);
      engine.dispose();

      advance(const Duration(minutes: 2));
      final restoredStats = StatsStore();
      final restored = TimerEngine(
        settings,
        restoredStats,
        clock: () => clock,
        store: store,
        effectsEnabled: false,
      );
      addTearDown(restored.dispose);
      await restored.restore();

      expect(restored.running, isFalse);
      expect(restored.phase, Phase.rest);
      expect(restored.sessionCount, 1);
      expect(restoredStats.totalSessions, 1);

      await restored.restore();
      expect(restoredStats.totalSessions, 1);
    });
  });
}
