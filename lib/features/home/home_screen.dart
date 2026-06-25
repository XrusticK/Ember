import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/models/quote.dart';
import '../../data/quotes_repository.dart';
import '../../state/app_state.dart';
import '../../widgets/premium_banner.dart';
import '../../widgets/quote_card.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/streak_celebration.dart';
import '../paywall/paywall_screen.dart';
import '../settings/settings_sheet.dart';

/// Главный экран: «мысль дня» + стрик + архив прочитанного.
/// Каждый день карточка дня новая. После «Прочитал» она уходит в архив —
/// в архиве копятся только прочитанные карточки.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Quote>> _all;

  @override
  void initState() {
    super.initState();
    _all = context.read<QuotesRepository>().loadAll();
  }

  /// Детерминированно выбираем «мысль дня» по дню в году.
  Quote _quoteOfDay(List<Quote> list) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return list[dayOfYear % list.length];
  }

  Future<void> _onRead(String quoteId) async {
    final app = context.read<AppState>();
    final grew = await app.markTodayRead(quoteId: quoteId);
    if (grew && mounted) {
      await showStreakCelebration(context, app.streak);
    }
  }

  void _openPaywall() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 16,
        title: const Text(
          'Ember',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        actions: [
          Center(child: StreakBadge(count: app.streak)),
          IconButton(
            tooltip: 'Настройки',
            icon: const Icon(Icons.tune),
            onPressed: () => SettingsSheet.show(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Quote>>(
        future: _all,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data!;
          final byId = {for (final q in all) q.id: q};

          // Лента под выбранную тему (с фолбэком на все карточки).
          final themed = all
              .where((q) => q.theme == app.selectedTheme.id)
              .toList();
          final pool = themed.isEmpty ? all : themed;

          final today = _quoteOfDay(pool);
          final read = app.isTodayRead;

          // Архив = прочитанные карточки, новые сверху.
          final archive = app.readQuotes.reversed
              .map((id) => byId[id])
              .whereType<Quote>()
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _sectionLabel('Мысль дня'),
              const SizedBox(height: 12),
              if (!read) ...[
                QuoteCard(
                  quote: today,
                  hero: true,
                  isFavorite: app.isFavorite(today.id),
                  onFavorite: () => app.toggleFavorite(today.id),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _onRead(today.id),
                  icon: const Icon(Icons.local_fire_department),
                  label: const Text('Прочитал — поддержать огонёк'),
                ),
              ] else
                _ReadConfirmation(streak: app.streak),
              if (!app.isPremium) ...[
                const SizedBox(height: 16),
                PremiumBanner(onTap: _openPaywall),
              ],
              const SizedBox(height: 28),
              _sectionLabel('Прочитано · ${archive.length}'),
              const SizedBox(height: 12),
              if (archive.isEmpty)
                const _EmptyArchiveHint()
              else
                ...archive.map(
                  (q) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QuoteCard(
                      quote: q,
                      isFavorite: app.isFavorite(q.id),
                      onFavorite: () => app.toggleFavorite(q.id),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      letterSpacing: 0.5,
      color: EmberColors.textMuted,
      fontWeight: FontWeight.w600,
    ),
  );
}

/// Компактное подтверждение, когда мысль дня уже прочитана.
class _ReadConfirmation extends StatelessWidget {
  const _ReadConfirmation({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: EmberColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EmberColors.ember.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: EmberColors.emberSoft),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Прочитано сегодня',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Возвращайся завтра за новой мыслью — огонёк горит $streak дн.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: EmberColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Подсказка для пустого архива.
class _EmptyArchiveHint extends StatelessWidget {
  const _EmptyArchiveHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: EmberColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            color: EmberColors.textMuted,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            'Архив пока пуст',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Каждый день — новая карточка. Прочитанные мысли копятся здесь.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: EmberColors.textMuted),
          ),
        ],
      ),
    );
  }
}
