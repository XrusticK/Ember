import 'package:flutter/material.dart';

/// Палитра «Ember» — тёплый уголёк на тёмном фоне.
class EmberColors {
  EmberColors._();

  static const background = Color(0xFF14110F);
  static const surface = Color(0xFF1F1A17);
  static const surfaceAlt = Color(0xFF2A2320);
  static const ember = Color(0xFFFF7A18); // оранжевый огонёк
  static const emberSoft = Color(0xFFFFB061);
  static const textPrimary = Color(0xFFF5EFE9);
  static const textMuted = Color(0xFF9C9088);
}

ThemeData buildEmberTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: EmberColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: EmberColors.ember,
      secondary: EmberColors.emberSoft,
      surface: EmberColors.surface,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: EmberColors.textPrimary,
      displayColor: EmberColors.textPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: EmberColors.ember,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
