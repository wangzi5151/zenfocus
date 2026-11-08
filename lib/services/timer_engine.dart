import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/strings.dart';
import 'notification_service.dart';
import 'noise_player.dart';
import 'settings_provider.dart';
import 'stats_store.dart';

enum Phase { focus, rest, longRest }

/// Persists enough timer state to survive the process being killed while in
/// the background. End time is stored as a wall-clock timestamp so elapsed
/// time can be reconstructed reliably after the app is resumed.
class TimerStateStore {
  static const _key = 'timer_state_v1';

  Future<Map<String, dynamic>?> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  Future<void> save(Map<String, dynamic>? state) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (state == null) {
        await p.remove(_key);
      } else {
        await p.setString(_key, jsonEncode(state));
      }
    } catch (_) {}
  }
}

class TimerEngine extends ChangeNotifier with WidgetsBindingObserver {
  TimerEngine(
    this.settings,
    this.stats, {
    DateTime Function()? clock,
    TimerStateStore? store,
    bool effectsEnabled = true,
  })  : _clock = clock ?? DateTime.now,
        _store = store,
        _effectsEnabled = effectsEnabled {
    remaining = total;
  }

  final SettingsProvider settings;
  final StatsStore stats;
  final DateTime Function() _clock;
  final TimerStateStore? _store;
  final bool _effectsEnabled;

  Phase phase = Phase.focus;
  bool running = false;
  late int remaining;
  int sessionCount = 0;
  Timer? _ticker;
  DateTime? _endAt;
  bool _lifecycleAttached = false;

  int get total {
    switch (phase) {
      case Phase.focus:
        return settings.focusMin * 60;
      case Phase.rest:
        return settings.breakMin * 60;
      case Phase.longRest:
        return settings.longBreakMin * 60;
    }
  }

  double get progress => total == 0 ? 0 : 1 - remaining / total;
  bool get isFocus => phase == Phase.focus;
  bool get isLongRest => phase == Phase.longRest;

  String get phaseLabel {
    switch (phase) {
      case Phase.focus:
        return tr('专注中', 'Focus');
      case Phase.rest:
        return tr('休息中', 'Break');
      case Phase.longRest:
        return tr('长休息', 'Long Break');
    }
  }

  void syncIdleDuration() {
    if (!running) {
      remaining = total;
      _saveState();
      notifyListeners();
    }
  }

  void start() {
    if (running) return;
    if (remaining <= 0) remaining = total;
    running = true;
    _endAt = _clock().add(Duration(seconds: remaining));
    _startTicker();
    _updateNoise();
    _saveState();
    notifyListeners();
  }

  void pause() {
    if (!running) return;
    remaining = _secondsUntilEnd();
    running = false;
    _endAt = null;
    _ticker?.cancel();
    _updateNoise();
    _saveState();
    notifyListeners();
  }

  void toggle() => running ? pause() : start();

  void reset() {
    _ticker?.cancel();
    running = false;
    _endAt = null;
    remaining = total;
    _updateNoise();
    _saveState();
    notifyListeners();
  }

  void skip() {
    _complete(counted: false);
  }

  void refreshNoise() {
    _updateNoise();
  }

  /// Registers lifecycle callbacks so the timer is reconciled with wall-clock
  /// time after the app returns from background / lock screen.
  void attachLifecycle() {
    if (_lifecycleAttached) return;
    WidgetsBinding.instance.addObserver(this);
    _lifecycleAttached = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _saveState();
        break;
      case AppLifecycleState.resumed:
        syncFromClock();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  /// Recomputes [remaining] from the persisted wall-clock end time. This is
  /// safe to call at any time and is what the UI ticker uses, so a throttled
  /// or paused [Timer.periodic] can never make the countdown drift.
  void syncFromClock() {
    if (!running || _endAt == null) return;
    final seconds = _secondsUntilEnd();
    if (seconds <= 0) {
      remaining = 0;
      _complete(counted: true);
      return;
    }
    if (seconds != remaining) {
      remaining = seconds;
      notifyListeners();
    }
  }

  /// Restores a previous session (e.g. after the app was killed). If the
  /// saved end time has already passed, the phase is completed exactly once.
  Future<void> restore() async {
    final saved = await _store?.load();
    if (saved == null) {
      remaining = total;
      notifyListeners();
      return;
    }

    final phaseIndex = (saved['phase'] as num?)?.toInt() ?? 0;
    phase = phaseIndex >= 0 && phaseIndex < Phase.values.length
        ? Phase.values[phaseIndex]
        : Phase.focus;
    sessionCount = (saved['sessionCount'] as num?)?.toInt() ?? 0;

    final endAtRaw = saved['endAt'] as String?;
    final endAt = endAtRaw == null ? null : DateTime.tryParse(endAtRaw);
    final wasRunning = saved['running'] == true && endAt != null;

    if (wasRunning) {
      running = true;
      _endAt = endAt;
      _startTicker();
      syncFromClock();
      return;
    }

    running = false;
    _endAt = null;
    final restored = (saved['remaining'] as num?)?.toInt() ?? total;
    remaining = restored.clamp(0, total).toInt();
    notifyListeners();
  }

  int _secondsUntilEnd() {
    final endAt = _endAt;
    if (endAt == null) return remaining;
    final ms = endAt.difference(_clock()).inMilliseconds;
    if (ms <= 0) return 0;
    return (ms / 1000).ceil();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => syncFromClock());
  }

  void _complete({required bool counted}) {
    _ticker?.cancel();
    running = false;
    _endAt = null;

    if (isFocus) {
      if (counted) {
        stats.addSession(settings.focusMin);
        sessionCount++;
      }
      if (_effectsEnabled) {
        NotificationService.instance.show(
          tr('专注完成', 'Focus complete'),
          tr('干得漂亮，休息一下吧', 'Well done. Time for a break.'),
        );
        if (settings.vibrateOnComplete) {
          HapticFeedback.heavyImpact();
        }
      }

      if (sessionCount > 0 &&
          sessionCount % settings.sessionsBeforeLongBreak == 0) {
        phase = Phase.longRest;
      } else {
        phase = Phase.rest;
      }
    } else {
      if (_effectsEnabled) {
        NotificationService.instance.show(
          tr('休息结束', 'Break over'),
          tr('准备好开始下一轮专注了吗', 'Ready for the next round?'),
        );
        if (settings.vibrateOnComplete) {
          HapticFeedback.mediumImpact();
        }
      }
      phase = Phase.focus;
    }

    remaining = total;

    if (settings.autoStart && counted) {
      start();
    } else {
      _updateNoise();
    }

    _saveState();
    notifyListeners();
  }

  void _saveState() {
    _store?.save({
      'phase': phase.index,
      'remaining': remaining,
      'sessionCount': sessionCount,
      'running': running,
      'endAt': _endAt?.toIso8601String(),
    });
  }

  void _updateNoise() {
    if (!_effectsEnabled) return;
    NoisePlayer.instance.setEnabled(
      running && settings.noiseOn,
      sound: settings.soundType,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    if (_lifecycleAttached) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
}
