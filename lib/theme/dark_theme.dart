import 'package:flutter/material.dart';

import 'app_colors.dart';

class DarkTheme {
  DarkTheme._();

  static final ThemeData data = _build(AppColors.dark);

  static ThemeData _build(LuxoraThemeColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.scaffoldBg,
      fontFamily: 'Poppins',
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.scaffoldBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textDark),
        titleTextStyle: TextStyle(
          color: colors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: colors.accent,
        secondary: colors.goldAccent,
        surface: colors.card,
        onPrimary: colors.primary,
        onSecondary: colors.primary,
        onSurface: colors.textDark,
      ),
      cardColor: colors.card,
      dividerColor: colors.divider,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: colors.textDark,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: colors.textDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: colors.textDark),
        bodyMedium: TextStyle(color: colors.textLight),
        bodySmall: TextStyle(color: colors.textLight),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: colors.textLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colors.accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textInverse,
          elevation: 0,
          shadowColor: colors.accent.withValues(alpha: 0.22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.scaffoldBg,
        selectedItemColor: colors.accent,
        unselectedItemColor: colors.textLight,
        selectedIconTheme: IconThemeData(size: 28, color: colors.accent),
        unselectedIconTheme: IconThemeData(size: 24, color: colors.textLight),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12, color: colors.textLight),
        elevation: 12,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.card,
        contentTextStyle: TextStyle(color: colors.textDark),
      ),
    );
  }
}
