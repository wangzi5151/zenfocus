import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/strings.dart';

enum AmbientSound { brownNoise, whiteNoise, rain, forest, deepFocus }

class SettingsProvider extends ChangeNotifier {
  static const _kFocus = 'focusMin';
  static const _kBreak = 'breakMin';
  static const _kGoal = 'dailyGoal';
  static const _kTheme = 'themeMode';
  static const _kLang = 'lang';
  static const _kAuto = 'autoStart';
  static const _kNoise = 'noiseOn';
  static const _kVol = 'noiseVolume';
  static const _kSound = 'soundType';
  static const _kOnboarded = 'onboarded';
  static const _kLongBreak = 'longBreakMin';
  static const _kSessionsBeforeLB = 'sessionsBeforeLB';
  static const _kVibrate = 'vibrateOnComplete';

  int focusMin = 25;
  int breakMin = 5;
  int longBreakMin = 15;
  int sessionsBeforeLongBreak = 4;
  int dailyGoalSessions = 8;
  ThemeMode themeMode = ThemeMode.system;
  bool autoStart = false;
  bool noiseOn = true;
  double noiseVolume = 0.8;
  AmbientSound soundType = AmbientSound.brownNoise;
  bool onboarded = false;
  bool vibrateOnComplete = true;

  Lang get langPref => S.pref;
  SharedPreferences? _p;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    focusMin = _p!.getInt(_kFocus) ?? 25;
    breakMin = _p!.getInt(_kBreak) ?? 5;
    longBreakMin = _p!.getInt(_kLongBreak) ?? 15;
    sessionsBeforeLongBreak = _p!.getInt(_kSessionsBeforeLB) ?? 4;
    dailyGoalSessions = _p!.getInt(_kGoal) ?? 8;
    themeMode = ThemeMode.values[_p!.getInt(_kTheme) ?? 0];
    autoStart = _p!.getBool(_kAuto) ?? false;
    noiseOn = _p!.getBool(_kNoise) ?? true;
    noiseVolume = _p!.getDouble(_kVol) ?? 0.8;
    soundType = AmbientSound.values[_p!.getInt(_kSound) ?? 0];
    onboarded = _p!.getBool(_kOnboarded) ?? false;
    vibrateOnComplete = _p!.getBool(_kVibrate) ?? true;
    S.pref = Lang.values[_p!.getInt(_kLang) ?? 0];
    notifyListeners();
  }

  void completeOnboarding() {
    onboarded = true;
    _p?.setBool(_kOnboarded, true);
    notifyListeners();
  }

  void setFocus(int v) {
    focusMin = v.clamp(5, 90);
    _p?.setInt(_kFocus, focusMin);
    notifyListeners();
  }

  void setBreak(int v) {
    breakMin = v.clamp(1, 30);
    _p?.setInt(_kBreak, breakMin);
    notifyListeners();
  }

  void setLongBreak(int v) {
    longBreakMin = v.clamp(5, 45);
    _p?.setInt(_kLongBreak, longBreakMin);
    notifyListeners();
  }

  void setSessionsBeforeLongBreak(int v) {
    sessionsBeforeLongBreak = v.clamp(2, 8);
    _p?.setInt(_kSessionsBeforeLB, sessionsBeforeLongBreak);
    notifyListeners();
  }

  void setGoal(int v) {
    dailyGoalSessions = v.clamp(1, 16);
    _p?.setInt(_kGoal, dailyGoalSessions);
    notifyListeners();
  }

  void setTheme(ThemeMode m) {
    themeMode = m;
    _p?.setInt(_kTheme, m.index);
    notifyListeners();
  }

  void setLang(Lang l) {
    S.setPref(l);
    _p?.setInt(_kLang, l.index);
    notifyListeners();
  }

  void setAutoStart(bool v) {
    autoStart = v;
    _p?.setBool(_kAuto, v);
    notifyListeners();
  }

  void setNoise(bool v) {
    noiseOn = v;
    _p?.setBool(_kNoise, v);
    notifyListeners();
  }

  void setVolume(double v) {
    noiseVolume = v;
    _p?.setDouble(_kVol, v);
    notifyListeners();
  }

  void setSoundType(AmbientSound s) {
    soundType = s;
    _p?.setInt(_kSound, s.index);
    notifyListeners();
  }

  void setVibrate(bool v) {
    vibrateOnComplete = v;
    _p?.setBool(_kVibrate, v);
    notifyListeners();
  }
}
