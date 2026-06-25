# CLAUDE.md

Guidance for Claude Code (and humans) working in this repo.

## What this is

**Ember** — a Flutter test-assignment app. One thought-card per day (quote / advice /
mantra); reading it keeps a daily **streak** (🔥) alive. Premium unlocks the full
archive, all themes, and a streak-freeze. The streak is the retention mechanic; the
quotes are the cheap, pretty content on top of it.

This is a *demo built on screen-recording* — it must always run, never show a key on
camera, and never crash mid-flow. Offline-first by design.

## Required behavior (from the assignment)

1. **Onboarding** (2 screens) ending in a "Continue" button.
2. **Paywall** — two plans, Month / Year (year discounted, preselected). "Continue"
   *emulates* a purchase (no real billing) and writes a flag to storage.
3. **Home** — content (the daily card + an archive list).
4. **Persisted subscription** — if the user "bought", the next launch opens Home
   directly, skipping onboarding and paywall. Storage = `shared_preferences`.

## Startup routing (the core logic — keep it in one place)

Decided once, at launch, from persisted flags:

```
onboarding_done == false   -> Onboarding
else is_premium == false   -> Paywall
else                       -> Home
```

Put this in a single resolver (e.g. `AppState.resolveInitialRoute()` /
`app.dart`). Do **not** scatter these conditions across screens.

## SharedPreferences keys (the contract)

| key             | type         | meaning                                  |
|-----------------|--------------|------------------------------------------|
| `onboarding_done` | bool       | onboarding finished, don't show again    |
| `is_premium`      | bool       | "purchased" — routes straight to Home    |
| `streak_count`    | int        | consecutive days the card was read       |
| `last_open_date`  | String (ISO yyyy-MM-dd) | last day a card was marked read |
| `favorites`       | List<String> | ids of favorited cards                 |
| `selected_theme`  | String     | mood chosen in onboarding (Calm/Focus/…) |

Keys live as constants in `lib/core/constants.dart` — never type the raw strings
elsewhere.

## Streak rule

On "mark read": compare today vs `last_open_date`.
- same day → no change (idempotent)
- yesterday → `streak_count++`
- older / null → `streak_count = 1`

Then store today as `last_open_date`. Beware off-by-one and timezone: compare
*date only* (`yyyy-MM-dd`), never timestamps.

## Architecture

- **State:** `provider` (`ChangeNotifier`). One `AppState` holds premium / onboarding /
  streak / favorites and is the only thing that touches `PrefsService`.
- **Data:** `PrefsService` wraps SharedPreferences; `QuotesRepository` loads
  `assets/quotes.json` into `Quote` models. UI never reads prefs or assets directly.
- **Layering:** `core` (theme, constants) → `data` (service, repo, models) →
  `state` (AppState) → `features` (screens) → `widgets` (reusable UI).

```
lib/
  main.dart              # bootstrap: load prefs, provide AppState, runApp
  app.dart               # MaterialApp + initial-route resolver
  core/
    constants.dart       # pref keys, plan ids
    theme.dart           # ember palette, text styles
  data/
    prefs_service.dart
    quotes_repository.dart
    models/quote.dart
  state/
    app_state.dart       # ChangeNotifier — single source of truth
  features/
    onboarding/onboarding_screen.dart
    paywall/paywall_screen.dart
    home/home_screen.dart
  widgets/
    quote_card.dart
    streak_badge.dart
assets/
  quotes.json            # local content — app works fully offline
```

## Optional AI bonus

"Generate a thought for my mood" → Gemini API (model **Flash** — fast/cheap), seeded
by `selected_theme`. The API key goes in `--dart-define` (read via
`String.fromEnvironment`) — **never** committed, never on camera. This is strictly
optional; the offline JSON path satisfies the whole assignment on its own.

## Commands

```bash
flutter pub get
flutter run -d edge          # web, mobile-sized window — good for the screencast
flutter run -d windows       # desktop
flutter analyze              # lint — keep clean
flutter test                 # unit tests (streak logic is the priority to cover)
dart format lib              # format before committing
```

With the AI bonus:
```bash
flutter run -d edge --dart-define=GEMINI_API_KEY=xxxx
```

## Conventions

- Keep it small and readable — this is judged on clarity, not feature count.
- Business logic (streak, routing, purchase flag) goes in `AppState`/services and is
  unit-testable without widgets.
- No raw pref-key strings, no magic numbers — use `core/constants.dart`.
- Don't add packages beyond `provider`, `shared_preferences` (+ `http` only if the
  Gemini bonus is built) without a reason.
