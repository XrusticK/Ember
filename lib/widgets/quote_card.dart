import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/mood_style.dart';
import '../core/theme.dart';
import '../data/models/quote.dart';

/// Карточка-мысль. Шрифт и акцент подбираются под тему карточки.
/// hero — большая «мысль дня», обычная — компактная карточка архива.
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    this.hero = false,
    this.isFavorite = false,
    this.onFavorite,
  });

  final Quote quote;
  final bool hero;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final mood = MoodThemeInfo.fromId(quote.theme);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(hero ? 28 : 20),
      decoration: BoxDecoration(
        gradient: hero
            ? LinearGradient(
                colors: mood.cardGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hero ? null : EmberColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hero
              ? mood.accent.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: mood.accent,
                size: hero ? 28 : 20,
              ),
              const Spacer(),
              Text(
                mood.title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: mood.accent,
                ),
              ),
            ],
          ),
          SizedBox(height: hero ? 18 : 12),
          Text(quote.text, style: mood.quoteStyle(fontSize: hero ? 24 : 16)),
          if (quote.author != null) ...[
            SizedBox(height: hero ? 16 : 10),
            Text(
              '— ${quote.author}',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: EmberColors.textMuted,
              ),
            ),
          ],
          if (onFavorite != null)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? mood.accent : EmberColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
