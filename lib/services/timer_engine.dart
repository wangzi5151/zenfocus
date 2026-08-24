import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/strings.dart';
import 'notification_service.dart';
import 'noise_player.dart';
import 'settings_provider.dart';
import 'stats_store.dart';

enum Phase { focus, rest, longRest }

class TimerEngine extends ChangeNotifier {
  TimerEngine(this.settings, this.stats);
  final SettingsProvider settings;
  final StatsStore stats;

  Phase phase = Phase.focus;
  bool running = false;
  int remaining = 25 * 60;
  int sessionCount = 0;
  Timer? _ticker;

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
      notifyListeners();
    }
  }

  void start() {
    if (running) return;
    running = true;
    _updateNoise();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void pause() {
    if (!running) return;
    running = false;
    _ticker?.cancel();
    _updateNoise();
    notifyListeners();
  }

  void toggle() => running ? pause() : start();

  void reset() {
    _ticker?.cancel();
    running = false;
    remaining = total;
    _updateNoise();
    notifyListeners();
  }

  void skip() {
    _complete(counted: false);
  }

  void refreshNoise() {
    _updateNoise();
  }

  void _tick() {
    if (remaining > 0) {
      remaining--;
      notifyListeners();
    }
    if (remaining <= 0) {
      _complete(counted: true);
    }
  }

  void _complete({required bool counted}) {
    _ticker?.cancel();
    running = false;

    if (isFocus) {
      if (counted) {
        stats.addSession(settings.focusMin);
        sessionCount++;
      }
      NotificationService.instance.show(
        tr('专注完成', 'Focus complete'),
        tr('干得漂亮，休息一下吧', 'Well done. Time for a break.'),
      );
      if (settings.vibrateOnComplete) {
        HapticFeedback.heavyImpact();
      }

      if (sessionCount > 0 &&
          sessionCount % settings.sessionsBeforeLongBreak == 0) {
        phase = Phase.longRest;
      } else {
        phase = Phase.rest;
      }
    } else {
      NotificationService.instance.show(
        tr('休息结束', 'Break over'),
        tr('准备好开始下一轮专注了吗', 'Ready for the next round?'),
      );
      if (settings.vibrateOnComplete) {
        HapticFeedback.mediumImpact();
      }
      phase = Phase.focus;
    }

    remaining = total;

    if (settings.autoStart && counted) {
      start();
    } else {
      _updateNoise();
    }

    notifyListeners();
  }

  void _updateNoise() {
    NoisePlayer.instance.setEnabled(
      running && settings.noiseOn,
      sound: settings.soundType,
    );
  }
}
