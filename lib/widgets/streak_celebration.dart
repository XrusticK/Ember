import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'ember_flame.dart';

/// Праздничный всплеск при росте стрика: крупный огонёк + число,
/// который вырастает, держится мгновение и исчезает.
Future<void> showStreakCelebration(BuildContext context, int streak) async {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(builder: (_) => _Celebration(streak: streak));
  overlay.insert(entry);
  await Future.delayed(const Duration(milliseconds: 1600));
  entry.remove();
}

class _Celebration extends StatelessWidget {
  const _Celebration({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, t, child) {
          // Лёгкое затемнение и всплывающий блок.
          final fade = t.clamp(0.0, 1.0);
          return Opacity(
            opacity: fade,
            child: Container(
              color: Colors.black.withValues(alpha: 0.55 * fade),
              alignment: Alignment.center,
              child: Transform.scale(
                scale: 0.7 + 0.3 * t,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EmberFlame(size: 96),
                    const SizedBox(height: 16),
                    Text(
                      'Стрик $streak!',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: EmberColors.emberSoft,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Огонёк горит ярче',
                      style: TextStyle(
                        fontSize: 15,
                        color: EmberColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
