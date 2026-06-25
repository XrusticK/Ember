import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Золотистый баннер-приглашение в Premium. Показывается бесплатным
/// пользователям; тап ведёт на пейвол.
class PremiumBanner extends StatelessWidget {
  const PremiumBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              EmberColors.gold.withValues(alpha: 0.22),
              EmberColors.ember.withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(color: EmberColors.gold.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: EmberColors.gold),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Открой Ember Premium',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Весь архив, все темы и заморозка стрика',
                    style: TextStyle(
                      fontSize: 13,
                      color: EmberColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: EmberColors.gold),
          ],
        ),
      ),
    );
  }
}
