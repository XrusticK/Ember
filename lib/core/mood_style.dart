import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';
import 'theme.dart';

/// Визуальная «фишка» каждой темы: свой акцентный цвет и свой шрифт цитаты.
/// Спокойствие — мягкий serif Lora, Фокус — гротеск Manrope,
/// Мотивация — плотный Montserrat, Стоицизм — классический Playfair Display.
extension MoodStyle on MoodTheme {
  Color get accent => switch (this) {
    MoodTheme.calm => const Color(0xFF7FB8A6),
    MoodTheme.focus => const Color(0xFF5BA8E6),
    MoodTheme.motivation => EmberColors.ember,
    MoodTheme.stoicism => EmberColors.gold,
  };

  /// Лёгкий двухцветный градиент для фона карточки-героя.
  List<Color> get cardGradient => [
    Color.lerp(EmberColors.surfaceAlt, accent, 0.10)!,
    EmberColors.surface,
  ];

  TextStyle quoteStyle({required double fontSize, Color? color}) {
    final c = color ?? EmberColors.textPrimary;
    return switch (this) {
      MoodTheme.calm => GoogleFonts.lora(
        fontSize: fontSize,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: c,
      ),
      MoodTheme.focus => GoogleFonts.manrope(
        fontSize: fontSize,
        height: 1.35,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: c,
      ),
      MoodTheme.motivation => GoogleFonts.montserrat(
        fontSize: fontSize,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: c,
      ),
      MoodTheme.stoicism => GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: c,
      ),
    };
  }
}
