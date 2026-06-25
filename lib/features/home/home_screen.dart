import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/models/quote.dart';
import '../../data/quotes_repository.dart';
import '../../state/app_state.dart';
import '../../widgets/quote_card.dart';
import '../../widgets/streak_badge.dart';

/// Главный экран: мысль дня + стрик + архив.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Quote>> _quotes;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    final repo = context.read<QuotesRepository>();
    _quotes = repo.byTheme(app.selectedTheme.id);
  }

  /// Детерминированно выбираем «мысль дня» по дню в году.
  Quote _quoteOfDay(List<Quote> list) {
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    return list[dayOfYear % list.length];
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: const [
            Text('🔥', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Ember', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: StreakBadge(count: app.streak)),
          ),
        ],
      ),
      body: FutureBuilder<List<Quote>>(
        future: _quotes,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          final today = _quoteOfDay(list);
          final archive = list.where((q) => q.id != today.id).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const Text(
                'Мысль дня',
                style: TextStyle(fontSize: 15, color: EmberColors.textMuted),
              ),
              const SizedBox(height: 12),
              QuoteCard(
                quote: today,
                hero: true,
                isFavorite: app.isFavorite(today.id),
                onFavorite: () => app.toggleFavorite(today.id),
              ),
              const SizedBox(height: 16),
              _ReadButton(
                done: app.isTodayRead,
                onTap: () => app.markTodayRead(),
              ),
              const SizedBox(height: 28),
              const Text(
                'Архив',
                style: TextStyle(fontSize: 15, color: EmberColors.textMuted),
              ),
              const SizedBox(height: 12),
              ...archive.map((q) {
                final locked = !app.isPremium;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: QuoteCard(
                    quote: q,
                    locked: locked,
                    isFavorite: app.isFavorite(q.id),
                    onFavorite: locked ? null : () => app.toggleFavorite(q.id),
                  ),
                );
              }),
            ],
          );
        },
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EmberColors.ember.withValues(alpha: 0.4)),
        ),
        child: const Text(
          '✓ Прочитано сегодня',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: EmberColors.emberSoft,
          ),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.check),
      label: const Text('Прочитал'),
    );
  }
}
