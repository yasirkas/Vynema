import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../discover/data/models/media_item.dart';
import '../../data/favorites_repository.dart';

/// Provides the opened Hive box. Overridden in `main()` after the box is opened.
final favoritesBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError('favoritesBoxProvider must be overridden'),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(ref.watch(favoritesBoxProvider)),
);

/// Holds the in-memory list of favorites, kept in sync with Hive.
class FavoritesNotifier extends Notifier<List<MediaItem>> {
  late final FavoritesRepository _repository;

  @override
  List<MediaItem> build() {
    _repository = ref.watch(favoritesRepositoryProvider);
    return _repository.getAll();
  }

  bool isFavorite(MediaItem item) => state.contains(item);

  Future<void> toggle(MediaItem item) async {
    try {
      if (isFavorite(item)) {
        await _repository.remove(item);
      } else {
        await _repository.add(item);
      }
      state = _repository.getAll();
    } on HiveError {
      // Hive write failed — persisted state unchanged, UI stays consistent
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<MediaItem>>(
        FavoritesNotifier.new);

/// Convenience selector: is this specific item currently favorited?
final isFavoriteProvider = Provider.autoDispose.family<bool, MediaItem>(
  (ref, item) => ref.watch(favoritesProvider).contains(item),
);
