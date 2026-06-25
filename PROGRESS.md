# PROGRESS — Ember

Tracker for the test assignment. Tick items as they land.

**Repo:** https://github.com/XrusticK/Ember
**Stack:** Flutter 3.38.7 · Dart 3.10.7 · provider + shared_preferences
**Run target for screencast:** `flutter run -d edge` (mobile-sized window)

---

## Milestones

### 0. Scaffold
- [ ] `flutter create` project, set app name / package id
- [ ] add deps: `provider`, `shared_preferences`
- [ ] register `assets/quotes.json` in `pubspec.yaml`
- [ ] `core/constants.dart` (pref keys, plan ids), `core/theme.dart` (ember palette)

### 1. Data layer
- [ ] `Quote` model + `assets/quotes.json` (~15–20 cards across themes)
- [ ] `PrefsService` — typed get/set for every key in the contract
- [ ] `QuotesRepository` — load + parse JSON

### 2. State
- [ ] `AppState (ChangeNotifier)` — premium / onboarding / streak / favorites
- [ ] `resolveInitialRoute()` — onboarding → paywall → home
- [ ] streak logic (same-day idempotent / yesterday++ / reset) — **unit tested**

### 3. Screens (the assignment)
- [ ] **Onboarding** screen 1 — "One thought a day…" + ember illustration
- [ ] **Onboarding** screen 2 — mood pick (Calm / Focus / Motivation / Stoicism)
- [ ] "Continue" → set `onboarding_done`, go to Paywall
- [ ] **Paywall** — Month / Year cards, Year preselected & marked "−40%"
- [ ] Paywall "Continue" → set `is_premium = true`, go to Home
- [ ] **Home** — daily card + ✓ "Read" (advances streak)
- [ ] Home — streak badge (🔥 n) up top
- [ ] Home — archive list below, locked/blurred for free users
- [ ] favorite (❤️) toggle persisted

### 4. Persistence acceptance
- [ ] cold start as premium → lands on Home, skips onboarding + paywall
- [ ] cold start, onboarded but not premium → lands on Paywall
- [ ] cold start, fresh install → lands on Onboarding
- [ ] streak survives app restart

### 5. Polish
- [ ] `flutter analyze` clean
- [ ] `dart format lib`
- [ ] README (architecture / structure / "what I'd improve with more time")
- [ ] verify full flow on screencast run

### 6. Optional AI bonus (only if time allows)
- [ ] "Generate a thought for my mood" → Gemini Flash via `--dart-define` key
- [ ] graceful fallback to local JSON on error / no key

### 7. Ship
- [ ] git init + connect remote `https://github.com/XrusticK/Ember`
- [ ] commit + push

---

## Notes / decisions
- Offline-first: local JSON is the source of truth so the screencast never breaks.
- AI shown **during development** (codegen, refactor, bug-hunt) is the mandatory part;
  the in-app Gemini button is a bonus, not a requirement.
- Routing logic lives in exactly one place — see CLAUDE.md.

## What I'd improve with more time
- Real billing (`in_app_purchase`) behind the same `is_premium` flag.
- Streak-freeze + local notification reminder (premium perks).
- Migrate prefs to a small repository interface for testability / future backend.
- Theming per selected mood; richer card transitions.
