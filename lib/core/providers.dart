import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/discover/data/datasources/tmdb_remote_datasource.dart';
import '../features/discover/data/repositories/media_repository.dart';
import 'network/dio_client.dart';

/// Singleton [Dio] configured for the TMDB API.
final dioProvider = Provider<Dio>((ref) => createDioClient());

/// Remote data source bound to the shared [Dio] instance.
final tmdbDataSourceProvider = Provider<TmdbRemoteDataSource>(
  (ref) => TmdbRemoteDataSource(ref.watch(dioProvider)),
);

/// Repository the presentation layer depends on.
final mediaRepositoryProvider = Provider<MediaRepository>(
  (ref) => MediaRepository(ref.watch(tmdbDataSourceProvider)),
);

/// Controls light/dark theme. Dark is the default per design requirements.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
