import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'models/quote.dart';

/// Загружает карточки из локального ассета. Приложение полностью офлайн.
class QuotesRepository {
  List<Quote>? _cache;

  Future<List<Quote>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/quotes.json');
    final list = (jsonDecode(raw) as List)
        .map((e) => Quote.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache = list;
    return list;
  }

  /// Карточки выбранной темы (если темы нет — все).
  Future<List<Quote>> byTheme(String? themeId) async {
    final all = await loadAll();
    if (themeId == null) return all;
    final filtered = all.where((q) => q.theme == themeId).toList();
    return filtered.isEmpty ? all : filtered;
  }
}
