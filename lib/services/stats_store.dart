import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionRecord {
  final DateTime time;
  final int minutes;
  final bool completed;

  SessionRecord({required this.time, required this.minutes, this.completed = true});

  Map<String, dynamic> toJson() => {
        't': time.millisecondsSinceEpoch,
        'm': minutes,
        'c': completed,
      };

  factory SessionRecord.fromJson(Map<String, dynamic> j) => SessionRecord(
        time: DateTime.fromMillisecondsSinceEpoch((j['t'] as num).toInt()),
        minutes: (j['m'] as num).toInt(),
        completed: j['c'] as bool? ?? true,
      );
}

class StatsStore extends ChangeNotifier {
  static const _kKey = 'stats_v2';

  Map<String, int> minutes = {};
  Map<String, int> sessions = {};
  int totalMinutes = 0;
  int totalSessions = 0;
  int maxSessionsPerDay = 0;
  List<SessionRecord> history = [];

  SharedPreferences? _p;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    final raw = _p!.getString(_kKey);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        minutes = (j['m'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt()));
        sessions = (j['s'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt()));
        totalMinutes = (j['tm'] as num?)?.toInt() ??
            minutes.values.fold(0, (a, b) => a + b);
        totalSessions = (j['ts'] as num?)?.toInt() ??
            sessions.values.fold(0, (a, b) => a + b);
        maxSessionsPerDay = (j['mx'] as num?)?.toInt() ??
            (sessions.values.isEmpty
                ? 0
                : sessions.values.reduce((a, b) => a > b ? a : b));
        final hist = j['h'] as List<dynamic>?;
        history = hist
                ?.map((e) => SessionRecord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      } catch (_) {}
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
          'h': history.take(200).map((e) => e.toJson()).toList(),
        }));
  }

  static String keyOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void addSession(int mins, {bool completed = true}) {
    final now = DateTime.now();
    final k = keyOf(now);
    minutes[k] = (minutes[k] ?? 0) + mins;
    sessions[k] = (sessions[k] ?? 0) + 1;
    totalMinutes += mins;
    totalSessions++;
    if ((sessions[k] ?? 0) > maxSessionsPerDay) {
      maxSessionsPerDay = sessions[k]!;
    }
    history.insert(0, SessionRecord(time: now, minutes: mins, completed: completed));
    if (history.length > 200) history = history.sublist(0, 200);
    _persist();
    notifyListeners();
  }

  int todayMinutes() => minutes[keyOf(DateTime.now())] ?? 0;

  int todaySessions() => sessions[keyOf(DateTime.now())] ?? 0;

  List<MapEntry<DateTime, int>> last7Days() {
    final now = DateTime.now();
    final out = <MapEntry<DateTime, int>>[];
    for (var i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      out.add(MapEntry(d, minutes[keyOf(d)] ?? 0));
    }
    return out;
  }

  List<MapEntry<DateTime, int>> last30Days() {
    final now = DateTime.now();
    final out = <MapEntry<DateTime, int>>[];
    for (var i = 29; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      out.add(MapEntry(d, minutes[keyOf(d)] ?? 0));
    }
    return out;
  }

  int weekMinutes() {
    final now = DateTime.now();
    var total = 0;
    for (var i = 0; i < 7; i++) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      total += minutes[keyOf(d)] ?? 0;
    }
    return total;
  }

  int monthMinutes() {
    final now = DateTime.now();
    var total = 0;
    for (var i = 0; i < 30; i++) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      total += minutes[keyOf(d)] ?? 0;
    }
    return total;
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
