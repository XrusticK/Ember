// Чистая логика подсчёта стрика — без Flutter и без хранилища,
// чтобы её можно было покрыть юнит-тестами.

/// Дата в формате yyyy-MM-dd (только день, без времени и таймзоны).
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Считает новое значение стрика при отметке «прочитано» сегодня.
///
/// - тот же день  -> без изменений (идемпотентно)
/// - вчера        -> +1
/// - раньше / null-> сброс на 1
int nextStreak({
  required int current,
  required String? lastOpenDate,
  required DateTime today,
}) {
  if (lastOpenDate == null) return 1;
  if (lastOpenDate == dateKey(today)) return current;

  final yesterday = today.subtract(const Duration(days: 1));
  if (lastOpenDate == dateKey(yesterday)) return current + 1;

  return 1;
}
