import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsStore extends ChangeNotifier {
  static const _kKey = 'stats_v1';

  Map<String, int> minutes = {};
  Map<String, int> sessions = {};
  int totalMinutes = 0;
  int totalSessions = 0;
  int maxSessionsPerDay = 0;

  SharedPreferences? _p;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    final raw = _p!.getString(_kKey);
    if (raw != null) {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      minutes = (j['m'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toInt()));
      sessions = (j['s'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toInt()));
      totalMinutes = (j['tm'] as num?)?.toInt() ??
          minutes.values.fold(0, (a, b) => a + b);
      totalSessions = (j['ts'] as num?)?.toInt() ??
          sessions.values.fold(0, (a, b) => a + b);
      maxSessionsPerDay = (j['mx'] as num?)?.toInt() ??
          (sessions.values.isEmpty
              ? 0
              : sessions.values.reduce((a, b) => a > b ? a : b));
    }
  }

  Future<void> _persist() async {
    await _p?.setString(
        _kKey,
        jsonEncode({
          'm': minutes,
          's': sessions,
          'tm': totalMinutes,
          'ts': totalSessions,
          'mx': maxSessionsPerDay,
        }));
  }

  static String keyOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void addSession(int mins) {
    final k = keyOf(DateTime.now());
    minutes[k] = (minutes[k] ?? 0) + mins;
    sessions[k] = (sessions[k] ?? 0) + 1;
    totalMinutes += mins;
    totalSessions++;
    if ((sessions[k] ?? 0) > maxSessionsPerDay) {
      maxSessionsPerDay = sessions[k]!;
    }
    _persist();
    notifyListeners();
  }

  int todayMinutes() => minutes[keyOf(DateTime.now())] ?? 0;

  int todaySessions() => sessions[keyOf(DateTime.now())] ?? 0;

  List<MapEntry<DateTime, int>> last7Days() {
    final now = DateTime.now();
    final out = <MapEntry<DateTime, int>>[];
    for (var i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      out.add(MapEntry(d, minutes[keyOf(d)] ?? 0));
    }
    return out;
  }

  int streak() {
    var day = DateTime.now();
    if ((sessions[keyOf(day)] ?? 0) == 0) {
      day = DateTime(day.year, day.month, day.day - 1);
    }
    var n = 0;
    while ((sessions[keyOf(day)] ?? 0) > 0) {
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }
}
