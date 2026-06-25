import 'package:ember/data/notification_service.dart';
import 'package:ember/data/prefs_service.dart';
import 'package:ember/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<AppState> buildState() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PrefsService.create();
    return AppState(prefs, NotificationService());
  }

  test('прочитанные карточки копятся в архиве в порядке прочтения', () async {
    final app = await buildState();
    expect(app.readQuotes, isEmpty);

    await app.markTodayRead(quoteId: 'q001', now: DateTime(2026, 6, 25));
    await app.markTodayRead(quoteId: 'q050', now: DateTime(2026, 6, 26));

    expect(app.readQuotes, ['q001', 'q050']);
    expect(app.isRead('q001'), isTrue);
    expect(app.isRead('q077'), isFalse);
  });

  test('повторное прочтение той же карточки не создаёт дубль', () async {
    final app = await buildState();
    await app.markTodayRead(quoteId: 'q001', now: DateTime(2026, 6, 25));
    await app.markTodayRead(quoteId: 'q001', now: DateTime(2026, 6, 25));

    expect(app.readQuotes, ['q001']);
  });
}
