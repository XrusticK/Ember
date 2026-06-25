import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Палитра «Ember» — тёплый уголёк на глубоком тёмном фоне + золотой premium-акцент.
class EmberColors {
  EmberColors._();

  static const background = Color(0xFF120F0D);
  static const surface = Color(0xFF1E1916);
  static const surfaceAlt = Color(0xFF2A231F);
  static const ember = Color(0xFFFF7A18); // основной огонёк
  static const emberSoft = Color(0xFFFFB061);
  static const gold = Color(0xFFF4B740); // premium-акцент
  static const textPrimary = Color(0xFFF6EFE8);
  static const textMuted = Color(0xFF9A8C82);
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
    // Базовый шрифт интерфейса — Manrope (чистый, премиальный).
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: EmberColors.textPrimary,
      displayColor: EmberColors.textPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: EmberColors.ember,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(56),
        textStyle: GoogleFonts.manrope(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}
