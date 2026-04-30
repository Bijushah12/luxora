import 'package:flutter/material.dart';

/// Forces light theme (Titan-inspired) across the app.
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeMode get currentTheme => ThemeMode.light;

  void toggleTheme() {
    // Light theme is enforced; toggle is disabled.
    _isDark = false;
    notifyListeners();
  }
}
