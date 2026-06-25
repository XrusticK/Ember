/// Ключи хранилища (SharedPreferences) — единственное место, где они объявлены.
/// Сырые строки ключей нигде больше в коде не должны встречаться.
class PrefKeys {
  PrefKeys._();

  static const onboardingDone = 'onboarding_done';
  static const isPremium = 'is_premium';
  static const streakCount = 'streak_count';
  static const lastOpenDate = 'last_open_date';
  static const favorites = 'favorites';
  static const selectedTheme = 'selected_theme';
}

/// Тарифные планы на пейволле.
enum SubscriptionPlan { month, year }

extension SubscriptionPlanInfo on SubscriptionPlan {
  String get id => switch (this) {
    SubscriptionPlan.month => 'month',
    SubscriptionPlan.year => 'year',
  };

  String get title => switch (this) {
    SubscriptionPlan.month => 'Месяц',
    SubscriptionPlan.year => 'Год',
  };

  String get price => switch (this) {
    SubscriptionPlan.month => '299 ₽ / мес',
    SubscriptionPlan.year => '1 790 ₽ / год',
  };

  /// Подпись-выгода (показываем только у годового).
  String? get badge => switch (this) {
    SubscriptionPlan.month => null,
    SubscriptionPlan.year => '−40%',
  };

  String? get subtitle => switch (this) {
    SubscriptionPlan.month => null,
    SubscriptionPlan.year => 'около 149 ₽ в месяц',
  };
}

/// Темы (настроения) ленты — выбираются в онбординге.
enum MoodTheme { calm, focus, motivation, stoicism }

extension MoodThemeInfo on MoodTheme {
  String get id => switch (this) {
    MoodTheme.calm => 'calm',
    MoodTheme.focus => 'focus',
    MoodTheme.motivation => 'motivation',
    MoodTheme.stoicism => 'stoicism',
  };

  String get title => switch (this) {
    MoodTheme.calm => 'Спокойствие',
    MoodTheme.focus => 'Фокус',
    MoodTheme.motivation => 'Мотивация',
    MoodTheme.stoicism => 'Стоицизм',
  };

  String get emoji => switch (this) {
    MoodTheme.calm => '🌿',
    MoodTheme.focus => '🎯',
    MoodTheme.motivation => '🔥',
    MoodTheme.stoicism => '🏛️',
  };

  static MoodTheme fromId(String? id) => MoodTheme.values.firstWhere(
    (t) => t.id == id,
    orElse: () => MoodTheme.motivation,
  );
}
