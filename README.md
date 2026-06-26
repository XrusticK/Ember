# 🔥 Ember

Одна мысль в день: открыл, прочитал, отметил → растёт **стрик** (огонёк). Тестовое
задание на Flutter, под iOS и Android, работает офлайн.

## По ТЗ

- **Онбординг** (2 экрана) + «Продолжить».
- **Пейвол** при входе: Месяц / Год (год −40%). «Продолжить» эмулирует покупку.
- **Главный экран**: мысль дня + архив прочитанного.
- **Сохранение состояния** (`shared_preferences`): купил → при следующем запуске пейвол
  пропускается, сразу главный экран.

## Сверх ТЗ

100 реальных цитат по 4 темам (свой шрифт и акцент у каждой), ежедневные пуши с выбором
времени, докупка в любой момент, анимированный огонёк и всплеск при росте стрика.

## Архитектура

Слоистая, на `provider`. Единый `AppState (ChangeNotifier)` — источник правды, только он
трогает `PrefsService`. Стартовый роутинг — в одном месте (`resolveInitialRoute`). Логика
стрика вынесена в чистую функцию и покрыта тестами.

```
lib/
  core/      constants, theme, mood_style
  data/      prefs_service, quotes_repository, notification_service, models/quote
  state/     app_state, streak
  features/  onboarding, paywall, home, settings
  widgets/   quote_card, streak_badge, ember_flame, streak_celebration, premium_banner
assets/quotes.json   test/ (стрик, онбординг, архив)
```

## Запуск

```bash
flutter pub get
flutter run        # iOS / Android
flutter test
```

## Что бы улучшил

- Реальный биллинг (`in_app_purchase`) за тем же флагом `is_premium`.
- Streak Freeze как настоящую premium-механику.
- Генерацию мысли под настроение через LLM (Gemini Flash) с фолбэком на JSON.
