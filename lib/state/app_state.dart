import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../data/notification_service.dart';
import '../data/prefs_service.dart';
import 'streak.dart';

/// Куда вести пользователя при запуске.
enum InitialRoute { onboarding, home }

/// Единственный источник правды по состоянию приложения.
/// Только этот класс трогает [PrefsService].
class AppState extends ChangeNotifier {
  AppState(this._prefs, this._notifications);

  final PrefsService _prefs;
  final NotificationService _notifications;

  bool get isPremium => _prefs.isPremium;
  bool get onboardingDone => _prefs.onboardingDone;
  int get streak => _prefs.streakCount;
  MoodTheme get selectedTheme => MoodThemeInfo.fromId(_prefs.selectedTheme);
  List<String> get favorites => _prefs.favorites;
  bool get reminderEnabled => _prefs.reminderEnabled;
  int get reminderHour => _prefs.reminderHour;

  /// Стартовый роутинг — решается один раз, в одном месте.
  /// Подписку можно купить когда угодно, поэтому она больше не блокирует вход:
  ///   onboarding_done == false -> онбординг
  ///   иначе                    -> главный экран
  InitialRoute resolveInitialRoute() =>
      onboardingDone ? InitialRoute.home : InitialRoute.onboarding;

  Future<void> completeOnboarding(MoodTheme theme) async {
    await _prefs.setSelectedTheme(theme.id);
    await _prefs.setOnboardingDone(true);
    notifyListeners();
  }

  Future<void> setTheme(MoodTheme theme) async {
    await _prefs.setSelectedTheme(theme.id);
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
  /// Возвращает true, если стрик увеличился (для праздничной анимации).
  Future<bool> markTodayRead({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final before = streak;
    final updated = nextStreak(
      current: streak,
      lastOpenDate: _prefs.lastOpenDate,
      today: today,
    );
    await _prefs.setStreakCount(updated);
    await _prefs.setLastOpenDate(dateKey(today));
    notifyListeners();
    return updated > before;
  }

  /// Засчитан ли уже сегодняшний день.
  bool get isTodayRead => _prefs.lastOpenDate == dateKey(DateTime.now());

  // --- Напоминания --------------------------------------------------------

  /// Включить/выключить ежедневное напоминание. При включении спрашиваем
  /// разрешение; если отказано — оставляем выключенным. Возвращает итог.
  Future<bool> setReminder(bool enabled, {int? hour}) async {
    if (enabled) {
      final granted = await _notifications.requestPermission();
      if (!granted) {
        await _prefs.setReminderEnabled(false);
        notifyListeners();
        return false;
      }
      final h = hour ?? reminderHour;
      await _prefs.setReminderHour(h);
      await _notifications.scheduleDaily(h);
      await _prefs.setReminderEnabled(true);
    } else {
      await _notifications.cancel();
      await _prefs.setReminderEnabled(false);
    }
    notifyListeners();
    return enabled;
  }
}
