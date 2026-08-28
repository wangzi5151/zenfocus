import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenfocus/core/theme/app_theme.dart';
import 'package:zenfocus/features/home/presentation/pages/home_page.dart';

void main() {
  runApp(const ZenFocusApp());
}

class ZenFocusApp extends StatelessWidget {
  const ZenFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenFocus 2.0',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      onGenerateRoute: (settings) {
        // TODO: Implement routing
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
        );
      },
    );
  }
}