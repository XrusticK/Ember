# 🔥 Ember — твоя ежедневная искра

Одна мысль в день (цитата / совет / мантра). Открыл, прочитал, отметил → растёт
**стрик** (огонёк). Огонёк горит, пока заходишь каждый день.

Тестовое задание на Flutter. Приложение под **iOS и Android**, работает офлайн.

## Что внутри (по ТЗ)

- **Онбординг** (2 экрана): смысл продукта → выбор настроения
  (Спокойствие · Фокус · Мотивация · Стоицизм). Кнопка «Продолжить».
- **Пейвол**: два плана — Месяц / Год (год дешевле, −40%, выбран по умолчанию).
  «Продолжить» *эмулирует* покупку (без реального биллинга) и пишет флаг в хранилище.
- **Главный экран**: «мысль дня» (новая каждый день) + кнопка «Прочитал», стрик,
  избранное. После прочтения карточка уходит в **архив** — там копятся только
  прочитанные карточки (личная история), новые сверху.
- **Сохранение состояния**: флаг `is_premium` и стрик персистентны
  (`shared_preferences`). Покупка переживает перезапуск, главный экран открывается
  сразу — онбординг и пейвол повторно не показываются.

### Сверх ТЗ (инициатива)

- Подписку можно купить **в любой момент** (баннер на главном экране), а не только
  на старте.
- **100 реальных цитат** по 4 темам; у каждой темы **свой шрифт и акцент**
  (Lora / Manrope / Montserrat / Playfair Display).
- **Пуши**: ежедневное локальное напоминание (включается в настройках, выбор времени).
- **Делайт**: анимированный огонёк, всплеск при росте стрика, плавные переходы,
  тёмно-«угольная» палитра с золотым акцентом.

## Архитектура

Слоистая, на `provider`:

```
core    → константы, тема, mood_style (шрифт + акцент под тему)
data    → PrefsService, QuotesRepository, NotificationService, модель Quote
state   → AppState (ChangeNotifier, единый источник правды) + чистая логика стрика
features→ экраны: onboarding / paywall / home / settings
widgets → QuoteCard, StreakBadge, EmberFlame, StreakCelebration, PremiumBanner
assets  → quotes.json (100 цитат, локальный контент)
```

Ключевые принципы:
- **Один источник правды.** `AppState` — единственный, кто трогает `PrefsService`;
  UI не читает хранилище и ассеты напрямую.
- **Роутинг в одном месте.** `AppState.resolveInitialRoute()`:
  `onboarding_done == false → онбординг`, иначе → главный экран.
- **Тестируемая логика.** Подсчёт стрика вынесен в чистую функцию
  (`state/streak.dart`) и покрыт юнит-тестами, без виджетов.

### Ключи хранилища

`onboarding_done`, `is_premium`, `streak_count`, `last_open_date`, `favorites`,
`selected_theme`, `reminder_enabled`, `reminder_hour`, `read_quotes`. Объявлены как
константы в `core/constants.dart`.

### Правило стрика

Сравниваем только дату (`yyyy-MM-dd`): тот же день — без изменений; вчера — `+1`;
раньше / пусто — сброс на `1`.

## Структура проекта

```
lib/
  main.dart, app.dart
  core/      constants.dart, theme.dart, mood_style.dart
  data/      prefs_service.dart, quotes_repository.dart, notification_service.dart, models/quote.dart
  state/     app_state.dart, streak.dart
  features/  onboarding/ paywall/ home/ settings/
  widgets/   quote_card, streak_badge, ember_flame, streak_celebration, premium_banner
assets/      quotes.json  (100 цитат)
test/        widget_test.dart, onboarding_flow_test.dart, read_archive_test.dart
```

## Запуск

```bash
flutter pub get
flutter run            # на эмуляторе/устройстве iOS или Android
flutter test           # тесты
flutter analyze        # линт
```

## Что бы улучшил при большем времени

- Реальный биллинг (`in_app_purchase`) за тем же флагом `is_premium`.
- Streak Freeze (заморозка стрика) как реальная premium-механика.
- Prefs за интерфейсом-репозиторием ради тестируемости и будущего бэкенда.
- Генерация мысли под настроение через LLM (например, Gemini Flash) с фолбэком на
  локальный JSON.
