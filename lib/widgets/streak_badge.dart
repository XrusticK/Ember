import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Счётчик стрика с огоньком: 🔥 7.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: EmberColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: EmberColors.emberSoft,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _dayWord(count),
            style: const TextStyle(fontSize: 13, color: EmberColors.textMuted),
          ),
        ],
      ),
    );
  }

  // Склонение «день / дня / дней».
  String _dayWord(int n) {
    final mod100 = n % 100;
    final mod10 = n % 10;
    if (mod100 >= 11 && mod100 <= 14) return 'дней';
    if (mod10 == 1) return 'день';
    if (mod10 >= 2 && mod10 <= 4) return 'дня';
    return 'дней';
  }
}
