import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:vynema/features/discover/data/models/media_item.dart';
import 'package:vynema/features/favorites/presentation/providers/favorites_provider.dart';

void main() {
  late Directory tempDir;
  late Box box;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_fav_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox('favorites');
  });

  tearDown(() async {
    await box.close();
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  ProviderContainer makeContainer() => ProviderContainer(
        overrides: [favoritesBoxProvider.overrideWithValue(box)],
      );

  const movie = MediaItem(
    id: 1,
    mediaType: MediaType.movie,
    title: 'Inception',
    overview: 'A dream within a dream.',
    posterPath: '/poster.jpg',
    backdropPath: null,
    voteAverage: 8.8,
    releaseDate: '2010-07-16',
  );

  const show = MediaItem(
    id: 2,
    mediaType: MediaType.tv,
    title: 'Breaking Bad',
    overview: 'Chemistry teacher turns to crime.',
    posterPath: null,
    backdropPath: null,
    voteAverage: 9.5,
    releaseDate: '2008-01-20',
  );

  group('FavoritesNotifier', () {
    test('initial state is empty', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(favoritesProvider), isEmpty);
    });

    test('toggle adds item when not favorited', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(favoritesProvider.notifier).toggle(movie);

      expect(container.read(favoritesProvider), contains(movie));
      expect(container.read(isFavoriteProvider(movie)), isTrue);
    });

    test('toggle removes item when already favorited', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(favoritesProvider.notifier).toggle(movie);
      await container.read(favoritesProvider.notifier).toggle(movie);

      expect(container.read(favoritesProvider), isEmpty);
      expect(container.read(isFavoriteProvider(movie)), isFalse);
    });

    test('multiple items tracked independently', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(favoritesProvider.notifier).toggle(movie);
      await container.read(favoritesProvider.notifier).toggle(show);

      expect(container.read(favoritesProvider), hasLength(2));
      expect(container.read(isFavoriteProvider(movie)), isTrue);
      expect(container.read(isFavoriteProvider(show)), isTrue);
    });

    test('toggle removes only targeted item, leaves others intact', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(favoritesProvider.notifier).toggle(movie);
      await container.read(favoritesProvider.notifier).toggle(show);
      await container.read(favoritesProvider.notifier).toggle(movie);

      expect(container.read(favoritesProvider), hasLength(1));
      expect(container.read(isFavoriteProvider(movie)), isFalse);
      expect(container.read(isFavoriteProvider(show)), isTrue);
    });

    test('state persists to Hive box', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(favoritesProvider.notifier).toggle(movie);

      expect(box.length, 1);
      expect(box.containsKey('movie_1'), isTrue);
    });

    test('removing item deletes key from Hive box', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(favoritesProvider.notifier).toggle(movie);
      await container.read(favoritesProvider.notifier).toggle(movie);

      expect(box.length, 0);
    });
  });
}
