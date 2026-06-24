import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../features/discover/data/datasources/tmdb_remote_datasource.dart';
import '../features/discover/data/repositories/media_repository.dart';
import 'network/dio_client.dart';

/// Hive box holding user settings (theme, locale). Overridden in `main`.
final settingsBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError('settingsBoxProvider must be overridden'),
);

/// Singleton [Dio] configured for the TMDB API.
///
/// Watches [localeProvider] so the `language` query parameter follows the
/// active app language; switching languages rebuilds the client and cascades a
/// refetch through every data provider, returning content in the new language.
final dioProvider = Provider<Dio>((ref) {
  final locale = ref.watch(localeProvider);
  return createDioClient(languageTag: tmdbLanguageTag(locale));
});

/// Remote data source bound to the shared [Dio] instance.
final tmdbDataSourceProvider = Provider<TmdbRemoteDataSource>(
  (ref) => TmdbRemoteDataSource(ref.watch(dioProvider)),
);

/// Repository the presentation layer depends on.
final mediaRepositoryProvider = Provider<MediaRepository>(
  (ref) => MediaRepository(ref.watch(tmdbDataSourceProvider)),
);

/// Maps a UI [Locale] to the TMDB `language` query value.
String tmdbLanguageTag(Locale locale) =>
    locale.languageCode == 'en' ? 'en-US' : 'tr-TR';

/// Controls light/dark theme, persisted in the settings box. Dark is the
/// default per design requirements.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'themeMode';

  Box get _box => ref.read(settingsBoxProvider);

  @override
  ThemeMode build() {
    final stored = _box.get(_key) as String?;
    return stored == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  void toggle() => setMode(
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      );

  void setMode(ThemeMode mode) {
    state = mode;
    try {
      _box.put(_key, mode == ThemeMode.light ? 'light' : 'dark');
    } on HiveError {
      // persist failure — in-memory state still updated
    }
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Controls the active app language, persisted in the settings box.
/// Turkish is the default per project requirements.
class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'locale';
  static const supported = [Locale('tr'), Locale('en')];

  Box get _box => ref.read(settingsBoxProvider);

  @override
  Locale build() {
    final stored = _box.get(_key) as String?;
    return stored == 'en' ? const Locale('en') : const Locale('tr');
  }

  void setLocale(Locale locale) {
    state = locale;
    try {
      _box.put(_key, locale.languageCode);
    } on HiveError {
      // persist failure — in-memory state still updated
    }
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
