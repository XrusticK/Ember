import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/ember_flame.dart';

/// Пейвол: два плана (Месяц / Год). Год выбран по умолчанию и выгоднее.
/// «Продолжить» эмулирует покупку и пишет флаг в хранилище.
/// Открывается по запросу (баннер / замок архива), подписку можно купить
/// в любой момент.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  SubscriptionPlan _selected = SubscriptionPlan.year; // год по умолчанию
  bool _busy = false;

  static const _perks = [
    'Streak Freeze — не потеряешь огонёк',
    'Несколько мыслей в день, а не одна',
    'Новые темы и подборки',
    'Безлимит избранного',
  ];

  Future<void> _purchase() async {
    setState(() => _busy = true);
    await context.read<AppState>().purchase(_selected);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium активирован 🔥 Архив открыт')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const EmberFlame(size: 64),
              const SizedBox(height: 16),
              const Text(
                'Ember Premium',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Не теряй свой огонёк и открой всё сразу.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: EmberColors.textMuted),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._perks.map(_perkRow),
                      const SizedBox(height: 24),
                      ...SubscriptionPlan.values.map(_planCard),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: FilledButton(
                  onPressed: _busy ? null : _purchase,
                  child: _busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('Продолжить'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Покупка эмулируется — реальной оплаты нет.',
                  style: TextStyle(fontSize: 12, color: EmberColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _perkRow(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        const Icon(Icons.check_circle, color: EmberColors.ember, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    ),
  );

  Widget _planCard(SubscriptionPlan plan) {
    final isOn = _selected == plan;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selected = plan),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: EmberColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOn ? EmberColors.ember : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isOn
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isOn ? EmberColors.ember : EmberColors.textMuted,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (plan.subtitle != null)
                    Text(
                      plan.subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: EmberColors.textMuted,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (plan.badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: EmberColors.ember,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    plan.badge!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                plan.price,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: EmberColors.emberSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
