import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'ember_flame.dart';

/// Счётчик стрика с живым огоньком. Если стрик 0 — огонёк «потух» (приглушён).
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final alive = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: EmberColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alive)
            const EmberFlame(size: 20)
          else
            Icon(
              Icons.local_fire_department_outlined,
              size: 20,
              color: EmberColors.textMuted,
            ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: alive ? EmberColors.emberSoft : EmberColors.textMuted,
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
