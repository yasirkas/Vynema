import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart';
import '../../../../core/providers.dart';

/// Settings tab — theme and language preferences (both persisted in Hive).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionTitle(l10n.settingsAppearance),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeModeProvider.notifier).setMode(mode);
              }
            },
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(l10n.themeDark),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  secondary: const Icon(Icons.light_mode_outlined),
                  title: Text(l10n.themeLight),
                ),
              ],
            ),
          ),
          const Divider(),
          _SectionTitle(l10n.settingsLanguage),
          RadioGroup<String>(
            groupValue: locale.languageCode,
            onChanged: (code) {
              if (code != null) {
                ref.read(localeProvider.notifier).setLocale(Locale(code));
              }
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'tr',
                  secondary: const Text('🇹🇷', style: TextStyle(fontSize: 22)),
                  title: Text(l10n.languageTurkish),
                ),
                RadioListTile<String>(
                  value: 'en',
                  secondary: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                  title: Text(l10n.languageEnglish),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
