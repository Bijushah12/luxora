import 'package:flutter/material.dart';

@immutable
class LuxoraThemeColors extends ThemeExtension<LuxoraThemeColors> {
  final Color background;
  final Color scaffoldBg;
  final Color card;
  final Color surface;
  final Color primary;
  final Color accent;
  final Color goldAccent;
  final Color textDark;
  final Color textLight;
  final Color textInverse;
  final Color border;
  final Color divider;
  final Color shadow;
  final Color success;
  final Color error;
  final Color warning;
  final Color glassBg;
  final Color glassBorder;
  final Color glassShadow;

  const LuxoraThemeColors({
    required this.background,
    required this.scaffoldBg,
    required this.card,
    required this.surface,
    required this.primary,
    required this.accent,
    required this.goldAccent,
    required this.textDark,
    required this.textLight,
    required this.textInverse,
    required this.border,
    required this.divider,
    required this.shadow,
    required this.success,
    required this.error,
    required this.warning,
    required this.glassBg,
    required this.glassBorder,
    required this.glassShadow,
  });

  @override
  LuxoraThemeColors copyWith({
    Color? background,
    Color? scaffoldBg,
    Color? card,
    Color? surface,
    Color? primary,
    Color? accent,
    Color? goldAccent,
    Color? textDark,
    Color? textLight,
    Color? textInverse,
    Color? border,
    Color? divider,
    Color? shadow,
    Color? success,
    Color? error,
    Color? warning,
    Color? glassBg,
    Color? glassBorder,
    Color? glassShadow,
  }) {
    return LuxoraThemeColors(
      background: background ?? this.background,
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      card: card ?? this.card,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      goldAccent: goldAccent ?? this.goldAccent,
      textDark: textDark ?? this.textDark,
      textLight: textLight ?? this.textLight,
      textInverse: textInverse ?? this.textInverse,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      glassBg: glassBg ?? this.glassBg,
      glassBorder: glassBorder ?? this.glassBorder,
      glassShadow: glassShadow ?? this.glassShadow,
    );
  }

  @override
  LuxoraThemeColors lerp(ThemeExtension<LuxoraThemeColors>? other, double t) {
    if (other is! LuxoraThemeColors) return this;
    return LuxoraThemeColors(
      background: Color.lerp(background, other.background, t)!,
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      card: Color.lerp(card, other.card, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      textDark: Color.lerp(textDark, other.textDark, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      glassBg: Color.lerp(glassBg, other.glassBg, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassShadow: Color.lerp(glassShadow, other.glassShadow, t)!,
    );
  }
}

class AppColors {
  AppColors._();

  // Current Luxora appearance. This remains the default theme.
  static const LuxoraThemeColors light = LuxoraThemeColors(
    background: Color(0xFFF8F9FA),
    scaffoldBg: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    surface: Color(0xFFF3F4F6),
    primary: Color(0xFF1A1A1A),
    accent: Color(0xFFC9A96E),
    goldAccent: Color(0xFFD4AF37),
    textDark: Color(0xFF1A1A1A),
    textLight: Color(0xFF6B7280),
    textInverse: Color(0xFFFFFFFF),
    border: Color(0xFFE5E7EB),
    divider: Color(0xFFF3F4F6),
    shadow: Color(0x1A000000),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    glassBg: Color(0xF0FFFFFF),
    glassBorder: Color(0x40FFFFFF),
    glassShadow: Color(0x0F000000),
  );

  static const LuxoraThemeColors dark = LuxoraThemeColors(
    background: Color(0xFF0B0B0D),
    scaffoldBg: Color(0xFF101113),
    card: Color(0xFF17181B),
    surface: Color(0xFF222328),
    primary: Color(0xFF050506),
    accent: Color(0xFFD3B77D),
    goldAccent: Color(0xFFE0BE5B),
    textDark: Color(0xFFF6F1E7),
    textLight: Color(0xFFAAA49A),
    textInverse: Color(0xFFFFFFFF),
    border: Color(0xFF2D2B28),
    divider: Color(0xFF232226),
    shadow: Color(0x66000000),
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    glassBg: Color(0xCC17181B),
    glassBorder: Color(0x33D3B77D),
    glassShadow: Color(0x52000000),
  );

  static LuxoraThemeColors _active = light;

  static LuxoraThemeColors get current => _active;

  static void useDarkMode(bool isDark) {
    _active = isDark ? dark : light;
  }

  // Registers widgets that still use AppColors with Flutter's theme updates.
  static void watch(BuildContext context) {
    Theme.of(context);
  }

  static Color get background => _active.background;
  static Color get scaffoldBg => _active.scaffoldBg;
  static Color get card => _active.card;
  static Color get surface => _active.surface;
  static Color get primary => _active.primary;
  static Color get accent => _active.accent;
  static Color get goldAccent => _active.goldAccent;
  static Color get primaryGold => _active.accent;
  static Color get accentGold => _active.goldAccent;
  static Color get darkBg => _active.textDark;
  static Color get textDark => _active.textDark;
  static Color get textLight => _active.textLight;
  static Color get textInverse => _active.textInverse;
  static Color get border => _active.border;
  static Color get divider => _active.divider;
  static Color get shadow => _active.shadow;
  static Color get success => _active.success;
  static Color get error => _active.error;
  static Color get warning => _active.warning;
  static Color get black => _active.textDark;
  static Color get darkSurface => _active.surface;
  static Color get glassBg => _active.glassBg;
  static Color get glassBorder => _active.glassBorder;
  static Color get glassShadow => _active.glassShadow;
}

extension LuxoraThemeContext on BuildContext {
  LuxoraThemeColors get luxoraColors =>
      Theme.of(this).extension<LuxoraThemeColors>() ?? AppColors.current;
}
