import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../data/prefs_service.dart';
import 'streak.dart';

/// Куда вести пользователя при запуске.
enum InitialRoute { onboarding, paywall, home }

/// Единственный источник правды по состоянию приложения.
/// Только этот класс трогает [PrefsService].
class AppState extends ChangeNotifier {
  AppState(this._prefs);

  final PrefsService _prefs;

  bool get isPremium => _prefs.isPremium;
  bool get onboardingDone => _prefs.onboardingDone;
  int get streak => _prefs.streakCount;
  MoodTheme get selectedTheme => MoodThemeInfo.fromId(_prefs.selectedTheme);
  List<String> get favorites => _prefs.favorites;

  /// Стартовый роутинг — решается один раз, в одном месте.
  ///   onboarding_done == false -> онбординг
  ///   is_premium == false      -> пейвол
  ///   иначе                    -> главный экран
  InitialRoute resolveInitialRoute() {
    if (!onboardingDone) return InitialRoute.onboarding;
    if (!isPremium) return InitialRoute.paywall;
    return InitialRoute.home;
  }

  Future<void> completeOnboarding(MoodTheme theme) async {
    await _prefs.setSelectedTheme(theme.id);
    await _prefs.setOnboardingDone(true);
    notifyListeners();
  }

  /// Эмуляция покупки — никакого реального биллинга.
  Future<void> purchase(SubscriptionPlan plan) async {
    await _prefs.setPremium(true);
    notifyListeners();
  }

  bool isFavorite(String quoteId) => favorites.contains(quoteId);

  Future<void> toggleFavorite(String quoteId) async {
    final list = List<String>.from(favorites);
    if (!list.remove(quoteId)) list.add(quoteId);
    await _prefs.setFavorites(list);
    notifyListeners();
  }

  /// Отметить карточку дня прочитанной и продвинуть стрик.
  Future<void> markTodayRead({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final updated = nextStreak(
      current: streak,
      lastOpenDate: _prefs.lastOpenDate,
      today: today,
    );
    await _prefs.setStreakCount(updated);
    await _prefs.setLastOpenDate(dateKey(today));
    notifyListeners();
  }

  /// Засчитан ли уже сегодняшний день.
  bool get isTodayRead => _prefs.lastOpenDate == dateKey(DateTime.now());
}
