import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/mood_style.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/ember_flame.dart';
import '../paywall/paywall_screen.dart';

/// Онбординг из двух экранов: смысл продукта -> выбор настроения.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  MoodTheme? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == 0) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final theme = _selected ?? MoodTheme.motivation;
    await context.read<AppState>().completeOnboarding(theme);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PaywallScreen(isGate: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _page == 0 || _selected != null;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  const _IntroPage(),
                  _MoodPage(
                    selected: _selected,
                    onSelect: (t) => setState(() => _selected = t),
                  ),
                ],
              ),
            ),
            _Dots(count: 2, active: _page),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: canContinue ? _next : null,
                child: Text(_page == 0 ? 'Продолжить' : 'Зажечь огонёк'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          EmberFlame(size: 120),
          SizedBox(height: 36),
          Text(
            'Одна мысль в день.\nБольшие сдвиги за год.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Заходи каждый день, отмечай прочитанное — '
            'и поддерживай свой огонёк. Пропустишь — он погаснет.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: EmberColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodPage extends StatelessWidget {
  const _MoodPage({required this.selected, required this.onSelect});

  final MoodTheme? selected;
  final ValueChanged<MoodTheme> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Что тебе ближе сейчас?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Подберём ленту и оформление под твоё настроение.',
            style: TextStyle(fontSize: 15, color: EmberColors.textMuted),
          ),
          const SizedBox(height: 24),
          ...MoodTheme.values.map((t) {
            final isOn = selected == t;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelect(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: EmberColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isOn ? t.accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      _MoodIcon(theme: t, active: isOn),
                      const SizedBox(width: 16),
                      Text(
                        t.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isOn ? t.accent : EmberColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (isOn) Icon(Icons.check_circle, color: t.accent),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MoodIcon extends StatelessWidget {
  const _MoodIcon({required this.theme, required this.active});

  final MoodTheme theme;
  final bool active;

  IconData get _icon => switch (theme) {
    MoodTheme.calm => Icons.spa_outlined,
    MoodTheme.focus => Icons.center_focus_strong_outlined,
    MoodTheme.motivation => Icons.bolt_outlined,
    MoodTheme.stoicism => Icons.account_balance_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.accent.withValues(alpha: active ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_icon, color: theme.accent),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final on = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: on ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: on ? EmberColors.ember : EmberColors.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
