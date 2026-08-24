import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) {
  const seed = Color(0xFF006A60);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  return ThemeData(colorScheme: scheme, useMaterial3: true);
}
