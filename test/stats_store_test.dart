import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenfocus/services/stats_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StatsStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('keyOf formats date correctly', () {
      expect(StatsStore.keyOf(DateTime(2026, 1, 5)), '2026-01-05');
      expect(StatsStore.keyOf(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('adds sessions and persists them', () async {
      final store = StatsStore();
      await store.load();
      store.addSession(25);
      store.addSession(30);

      expect(store.totalSessions, 2);
      expect(store.totalMinutes, 55);
      expect(store.todaySessions(), 2);
      expect(store.todayMinutes(), 55);

      await Future<void>.delayed(Duration.zero);
      final reloaded = StatsStore();
      await reloaded.load();
      expect(reloaded.totalSessions, 2);
      expect(reloaded.todaySessions(), 2);
      expect(reloaded.history.length, 2);
    });

    test('streak counts consecutive days including today', () async {
      final store = StatsStore();
      await store.load();
      final now = DateTime.now();
      for (var i = 0; i < 5; i++) {
        final day = DateTime(now.year, now.month, now.day - i);
        store.sessions[StatsStore.keyOf(day)] = 1;
      }
      expect(store.streak(), 5);

      store.sessions.remove(StatsStore.keyOf(now));
      expect(store.streak(), 4);
    });

    test('streak is zero without any sessions', () async {
      final store = StatsStore();
      await store.load();
      expect(store.streak(), 0);
    });

    test('exports and imports a JSON backup round-trip', () async {
      final source = StatsStore();
      await source.load();
      source.addSession(25);
      source.addSession(15);
      final backup = source.exportJson();
      final decoded = jsonDecode(backup) as Map<String, dynamic>;
      expect(decoded['schema'], 1);
      expect(decoded['stats'], isA<Map<String, dynamic>>());

      final target = StatsStore();
      await target.load();
      expect(await target.importJson(backup), isTrue);
      expect(target.totalSessions, 2);
      expect(target.totalMinutes, 40);
      expect(target.history.length, 2);
      expect(target.todaySessions(), 2);
    });

    test('accepts raw stats maps and rejects malformed backups', () async {
      final store = StatsStore();
      await store.load();
      store.addSession(25);
      final before = store.totalSessions;

      expect(await store.importJson('not-json'), isFalse);
      expect(await store.importJson('{"m": "bad", "s": {}}'), isFalse);
      expect(store.totalSessions, before);

      final raw = jsonEncode({
        'm': {StatsStore.keyOf(DateTime.now()): 90},
        's': {StatsStore.keyOf(DateTime.now()): 3},
      });
      expect(await store.importJson(raw), isTrue);
      expect(store.totalSessions, 3);
      expect(store.totalMinutes, 90);
    });
  });
}
