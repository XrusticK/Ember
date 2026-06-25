import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'state/app_state.dart';

class EmberApp extends StatelessWidget {
  const EmberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ember',
      debugShowCheckedModeBanner: false,
      theme: buildEmberTheme(),
      home: const _RootRouter(),
    );
  }
}

/// Решает стартовый экран один раз, при запуске.
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final route = context.read<AppState>().resolveInitialRoute();
    return switch (route) {
      InitialRoute.onboarding => const OnboardingScreen(),
      InitialRoute.home => const HomeScreen(),
    };
  }
}
