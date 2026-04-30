import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.scaffoldBg,
    fontFamily: "Poppins",

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.scaffoldBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textDark),
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.card,
      background: AppColors.background,
      onPrimary: AppColors.textInverse,
      onSecondary: AppColors.textDark,
      onSurface: AppColors.textDark,
      onBackground: AppColors.textDark,
    ),

    cardColor: AppColors.card,
    dividerColor: AppColors.divider,

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textDark,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textLight,
      ),
      bodySmall: TextStyle(
        color: AppColors.textLight,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.textLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.scaffoldBg,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textLight,
      selectedIconTheme: IconThemeData(size: 28, color: AppColors.accent),
      unselectedIconTheme: IconThemeData(size: 24, color: AppColors.textLight),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
      elevation: 8,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: "Poppins",

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.goldAccent,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
    ),

    cardColor: const Color(0xFF1E1E1E),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: AppColors.accent,
      unselectedItemColor: Colors.white70,
      selectedIconTheme: IconThemeData(size: 28, color: AppColors.accent),
      unselectedIconTheme: IconThemeData(size: 24, color: Colors.white70),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12, color: Colors.white70),
      elevation: 12,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );
}
