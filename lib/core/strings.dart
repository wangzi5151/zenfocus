import 'dart:ui';

enum Lang { system, zh, en }

String tr(String zh, String en) => S.tr(zh, en);

class S {
  static Lang pref = Lang.system;
  static Locale _system = const Locale('zh');

  static void init(Lang p, Locale systemLocale) {
    _system = systemLocale;
    pref = p;
    _resolve();
  }

  static void setPref(Lang l) {
    pref = l;
    _resolve();
  }

  static bool _resolvedZh = true;

  static void _resolve() {
    if (pref == Lang.zh) {
      _resolvedZh = true;
    } else if (pref == Lang.en) {
      _resolvedZh = false;
    } else {
      _resolvedZh = _system.languageCode.toLowerCase() != 'en';
    }
  }

  static String tr(String zh, String en) => _resolvedZh ? zh : en;
}
