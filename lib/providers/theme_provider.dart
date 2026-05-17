import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'luxora_is_dark_theme';

  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeMode get currentTheme => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    _isDark = preferences.getBool(_themePreferenceKey) ?? false;
    AppColors.useDarkMode(_isDark);
  }

  Future<void> setTheme(bool isDark) async {
    if (_isDark == isDark) return;

    _isDark = isDark;
    AppColors.useDarkMode(_isDark);
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themePreferenceKey, _isDark);
  }

  Future<void> toggleTheme() => setTheme(!_isDark);
}
