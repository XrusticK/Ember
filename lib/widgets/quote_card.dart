import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models/quote.dart';

/// Карточка-мысль. Может быть «героической» (большая, мысль дня)
/// или компактной (в архиве). Поддерживает блюр-замок для бесплатной версии.
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    this.hero = false,
    this.locked = false,
    this.isFavorite = false,
    this.onFavorite,
  });

  final Quote quote;
  final bool hero;
  final bool locked;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.all(hero ? 28 : 20),
      decoration: BoxDecoration(
        gradient: hero
            ? const LinearGradient(
                colors: [EmberColors.surfaceAlt, EmberColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hero ? null : EmberColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hero
              ? EmberColors.ember.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote.text,
            style: TextStyle(
              fontSize: hero ? 24 : 16,
              height: 1.35,
              fontWeight: hero ? FontWeight.w600 : FontWeight.w500,
              color: EmberColors.textPrimary,
            ),
          ),
          if (quote.author != null) ...[
            const SizedBox(height: 12),
            Text(
              '— ${quote.author}',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: EmberColors.textMuted,
              ),
            ),
          ],
          if (onFavorite != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? EmberColors.ember : EmberColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (!locked) return card;

    // Заблокированная карточка архива: размытие + замок (триггер пейвола).
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: card,
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              color: EmberColors.emberSoft.withValues(alpha: 0.9),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}
