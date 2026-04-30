import 'package:flutter/material.dart';

/// Light Theme Color Palette — Titan-inspired clean luxury
class AppColors {
  // Core backgrounds
  static const background = Color(0xFFF8F9FA); // Light gray-white background
  static const scaffoldBg = Color(0xFFFFFFFF); // Pure white scaffold
  static const card = Color(0xFFFFFFFF);       // Pure white cards
  static const surface = Color(0xFFF3F4F6);    // Slightly darker surface for inputs/chips

  // Primary & accent
  static const primary = Color(0xFF1A1A1A);    // Dark primary (buttons, headers)
  static const accent = Color(0xFFC9A96E);     // Sophisticated gold accent
  static const goldAccent = Color(0xFFD4AF37); // Bright gold for prices/highlights

  // Legacy aliases (updated to light theme values)
  static const primaryGold = Color(0xFFC9A96E);
  static const accentGold = Color(0xFFD4AF37);
  static const darkBg = Color(0xFF1A1A1A);     // Now used for dark text/headers only

  // Text colors
  static const textDark = Color(0xFF1A1A1A);   // Primary text
  static const textLight = Color(0xFF6B7280);  // Secondary/muted text
  static const textInverse = Color(0xFFFFFFFF); // White text on dark elements

  // Utility
  static const border = Color(0xFFE5E7EB);     // Subtle border
  static const divider = Color(0xFFF3F4F6);    // Divider color
  static const shadow = Color(0x1A000000);     // Subtle black shadow

  // Status colors
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Backward compatibility aliases (light theme mapped)
  static const black = Color(0xFF1A1A1A);
  static const dark = Color(0xFF1A1A1A);
  static const darkSurface = Color(0xFFF3F4F6);

  // Glassmorphism for professional UI
  static const glassBg = Color(0xF0FFFFFF);     // Frosted glass background
  static const glassBorder = Color(0x40FFFFFF); // Subtle glass border
  static const glassShadow = Color(0x0F000000); // Glass shadow
}
