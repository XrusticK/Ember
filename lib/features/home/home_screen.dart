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

/// Главный экран: мысль дня + стрик + архив (открывается после прочтения).
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

  Future<void> _onRead() async {
    final app = context.read<AppState>();
    final grew = await app.markTodayRead();
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
          // Лента под выбранную тему (с фолбэком на все карточки).
          final themed = snap.data!
              .where((q) => q.theme == app.selectedTheme.id)
              .toList();
          final list = themed.isEmpty ? snap.data! : themed;

          final today = _quoteOfDay(list);
          final archive = list.where((q) => q.id != today.id).toList();
          final read = app.isTodayRead;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _sectionLabel('Мысль дня'),
              const SizedBox(height: 12),
              QuoteCard(
                quote: today,
                hero: true,
                isFavorite: app.isFavorite(today.id),
                onFavorite: () => app.toggleFavorite(today.id),
              ),
              const SizedBox(height: 16),
              _ReadButton(done: read, onTap: _onRead),
              if (!app.isPremium) ...[
                const SizedBox(height: 16),
                PremiumBanner(onTap: _openPaywall),
              ],
              const SizedBox(height: 28),
              // Архив открывается только после прочтения сегодняшней карточки.
              if (!read)
                _ArchiveLockedHint()
              else ...[
                _sectionLabel('Архив'),
                const SizedBox(height: 12),
                ...archive.map((q) {
                  final locked = !app.isPremium;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QuoteCard(
                      quote: q,
                      locked: locked,
                      isFavorite: app.isFavorite(q.id),
                      onFavorite: locked
                          ? null
                          : () => app.toggleFavorite(q.id),
                      onTapLocked: locked ? _openPaywall : null,
                    ),
                  );
                }),
              ],
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

class _ArchiveLockedHint extends StatelessWidget {
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
            'Архив откроется сегодня',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Отметь мысль дня прочитанной — и ниже появятся другие карточки.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: EmberColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ReadButton extends StatelessWidget {
  const _ReadButton({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: EmberColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: EmberColors.ember.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: EmberColors.emberSoft, size: 20),
            SizedBox(width: 8),
            Text(
              'Прочитано сегодня',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: EmberColors.emberSoft,
              ),
            ),
          ],
        ),
      );
    }
    return FilledButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.local_fire_department),
      label: const Text('Прочитал — поддержать огонёк'),
    );
  }
}
