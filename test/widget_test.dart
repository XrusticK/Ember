import 'package:ember/state/streak.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextStreak', () {
    final today = DateTime(2026, 6, 25);

    test('первый день при пустой дате -> 1', () {
      expect(nextStreak(current: 0, lastOpenDate: null, today: today), 1);
    });

    test('повторно в тот же день -> без изменений (идемпотентно)', () {
      expect(
        nextStreak(current: 5, lastOpenDate: '2026-06-25', today: today),
        5,
      );
    });

    test('заходил вчера -> +1', () {
      expect(
        nextStreak(current: 5, lastOpenDate: '2026-06-24', today: today),
        6,
      );
    });

    test('пропуск дня -> сброс на 1', () {
      expect(
        nextStreak(current: 5, lastOpenDate: '2026-06-22', today: today),
        1,
      );
    });

    test('переход через месяц считается корректно', () {
      expect(
        nextStreak(
          current: 3,
          lastOpenDate: '2026-05-31',
          today: DateTime(2026, 6, 1),
        ),
        4,
      );
    });
  });

  group('dateKey', () {
    test('форматирует с ведущими нулями', () {
      expect(dateKey(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });
}
