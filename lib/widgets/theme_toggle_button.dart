import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class ThemeToggleButton extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const ThemeToggleButton({
    super.key,
    this.margin = const EdgeInsets.only(right: 12),
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = context.luxoraColors;
    final isDark = themeProvider.isDark;

    return Padding(
      padding: margin,
      child: Tooltip(
        message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        child: Semantics(
          button: true,
          label: isDark ? 'Dark mode enabled' : 'Light mode enabled',
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: themeProvider.toggleTheme,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: 46,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: isDark ? colors.surface : colors.card,
                border: Border.all(
                  color: isDark
                      ? colors.accent.withValues(alpha: 0.42)
                      : colors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withValues(
                      alpha: isDark ? 0.28 : 0.16,
                    ),
                    blurRadius: isDark ? 18 : 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey<bool>(isDark),
                  size: 18,
                  color: isDark ? colors.accent : colors.goldAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
