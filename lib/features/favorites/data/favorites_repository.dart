import 'package:hive/hive.dart';

import '../../discover/data/models/media_item.dart';

/// Persists favorite media to a Hive box.
///
/// Items are stored as JSON maps keyed by `"<type>_<id>"`, avoiding the need
/// for generated Hive type adapters.
class FavoritesRepository {
  FavoritesRepository(this._box);

  static const String boxName = 'favorites';

  final Box _box;

  String _keyFor(MediaItem item) => '${item.mediaType.asPath}_${item.id}';

  bool isFavorite(MediaItem item) => _box.containsKey(_keyFor(item));

  Future<void> add(MediaItem item) =>
      _box.put(_keyFor(item), item.toJson());

  Future<void> remove(MediaItem item) => _box.delete(_keyFor(item));

  /// Returns all favorites, most recently added first.
  List<MediaItem> getAll() {
    return _box.values
        .map((e) => MediaItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
        .reversed
        .toList();
  }
}
