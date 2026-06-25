import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Локальные пуш-уведомления: ежедневное напоминание зайти и поддержать огонёк.
/// Весь текст — на русском. На web — no-op (платформа не поддерживает).
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channelId = 'ember_daily';
  static const _notifId = 1001;

  Future<void> init() async {
    if (kIsWeb || _ready) return;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Если не удалось определить зону — остаёмся на UTC, не падаем.
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    _ready = true;
  }

  /// Запрос разрешения у пользователя (Android 13+ / iOS).
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await init();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, badge: true);
      return granted ?? false;
    }
    return false;
  }

  /// Запланировать ежедневное напоминание на [hour]:00.
  Future<void> scheduleDaily(int hour) async {
    if (kIsWeb) return;
    await init();
    await cancel();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Ежедневная искра',
        channelDescription: 'Напоминание прочитать мысль дня',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: _notifId,
      title: 'Твой огонёк ждёт',
      body: 'Загляни на минутку — прочитай мысль дня и сохрани стрик.',
      scheduledDate: _nextInstanceOf(hour),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // повтор каждый день
    );
  }

  Future<void> cancel() async {
    if (kIsWeb) return;
    await _plugin.cancel(id: _notifId);
  }

  tz.TZDateTime _nextInstanceOf(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
