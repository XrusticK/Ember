import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/mood_style.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

/// Нижний лист настроек: тема ленты и ежедневное напоминание.
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    backgroundColor: EmberColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const SettingsSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: EmberColors.surfaceAlt,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Тема ленты',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MoodTheme.values.map((t) {
              final isOn = app.selectedTheme == t;
              return ChoiceChip(
                label: Text(t.title),
                selected: isOn,
                onSelected: (_) => app.setTheme(t),
                showCheckmark: false,
                backgroundColor: EmberColors.surfaceAlt,
                selectedColor: t.accent.withValues(alpha: 0.25),
                side: BorderSide(color: isOn ? t.accent : Colors.transparent),
                labelStyle: TextStyle(
                  color: isOn ? t.accent : EmberColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Напоминание',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: EmberColors.ember,
            value: app.reminderEnabled,
            title: const Text('Ежедневный пуш'),
            subtitle: Text(
              app.reminderEnabled
                  ? 'Каждый день в ${app.reminderHour}:00'
                  : 'Напомним зайти и сохранить стрик',
              style: const TextStyle(color: EmberColors.textMuted),
            ),
            onChanged: (v) async {
              final ok = await app.setReminder(v);
              if (!context.mounted) return;
              if (v && !ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Разрешение на уведомления не выдано'),
                  ),
                );
              }
            },
          ),
          if (app.reminderEnabled) ...[
            const SizedBox(height: 8),
            const Text(
              'Время',
              style: TextStyle(fontSize: 13, color: EmberColors.textMuted),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetHours.map((h) {
                final isOn = app.reminderHour == h;
                return ChoiceChip(
                  label: Text('${h.toString().padLeft(2, '0')}:00'),
                  selected: isOn,
                  showCheckmark: false,
                  backgroundColor: EmberColors.surfaceAlt,
                  selectedColor: EmberColors.ember.withValues(alpha: 0.25),
                  side: BorderSide(
                    color: isOn ? EmberColors.ember : Colors.transparent,
                  ),
                  labelStyle: TextStyle(
                    color: isOn
                        ? EmberColors.emberSoft
                        : EmberColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => app.setReminder(true, hour: h),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Удобные пресеты времени напоминания.
  static const _presetHours = [7, 9, 12, 15, 18, 20, 22];
}
