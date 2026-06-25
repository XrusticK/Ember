import 'package:ember/data/notification_service.dart';
import 'package:ember/data/prefs_service.dart';
import 'package:ember/data/quotes_repository.dart';
import 'package:ember/features/onboarding/onboarding_screen.dart';
import 'package:ember/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    // В тестах не ходим в сеть за шрифтами — используем фолбэк.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Онбординг рендерится и кнопка ведёт ко второму экрану', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PrefsService.create();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AppState(prefs, NotificationService()),
          ),
          Provider(create: (_) => QuotesRepository()),
        ],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    // Первый экран онбординга.
    expect(find.textContaining('Одна мысль в день'), findsOneWidget);
    expect(find.text('Продолжить'), findsOneWidget);

    // Переход ко второму экрану — выбор настроения.
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Что тебе ближе сейчас?'), findsOneWidget);
    expect(find.text('Спокойствие'), findsOneWidget);
  });
}
