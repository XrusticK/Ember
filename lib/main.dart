import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/notification_service.dart';
import 'data/prefs_service.dart';
import 'data/quotes_repository.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await PrefsService.create();
  final notifications = NotificationService();
  await notifications.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState(prefs, notifications)),
        Provider(create: (_) => QuotesRepository()),
      ],
      child: const EmberApp(),
    ),
  );
}
