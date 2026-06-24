import '../datasources/tmdb_remote_datasource.dart';
import '../models/media_detail.dart';
import '../models/media_item.dart';

/// Coordinates media data access for the presentation layer.
///
/// Currently a thin pass-through over the remote data source; it exists so
/// providers depend on an abstraction and caching/offline can be added later
/// without touching the UI.
class MediaRepository {
  MediaRepository(this._remote);

  final TmdbRemoteDataSource _remote;

  Future<List<MediaItem>> getTrending() => _remote.getTrending();

  Future<List<MediaItem>> getPopularMovies() => _remote.getPopularMovies();

  Future<List<MediaItem>> getPopularTv() => _remote.getPopularTv();

  Future<List<MediaItem>> search(String query) =>
      _remote.searchMulti(query);

  Future<MediaDetail> getDetail(MediaType type, int id) =>
      _remote.getDetail(type, id);
}
