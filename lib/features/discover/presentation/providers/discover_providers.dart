import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/models/genre.dart';
import '../../data/models/media_item.dart';
import '../../data/models/person.dart';

final trendingProvider = FutureProvider.autoDispose<List<MediaItem>>(
  (ref) => ref.watch(mediaRepositoryProvider).getTrending(),
);

final popularMoviesProvider = FutureProvider.autoDispose<List<MediaItem>>(
  (ref) => ref.watch(mediaRepositoryProvider).getPopularMovies(),
);

final popularTvProvider = FutureProvider.autoDispose<List<MediaItem>>(
  (ref) => ref.watch(mediaRepositoryProvider).getPopularTv(),
);

final genresProvider =
    FutureProvider.autoDispose.family<List<Genre>, MediaType>(
  (ref, type) => ref.watch(mediaRepositoryProvider).getGenres(type),
);

/// Whether the home genre row shows movie or TV genres. Kept (not auto-dispose)
/// so the chosen type survives navigation away from and back to the home tab.
class GenreTypeNotifier extends Notifier<MediaType> {
  @override
  MediaType build() => MediaType.movie;

  void set(MediaType type) => state = type;
}

final genreTypeProvider =
    NotifierProvider<GenreTypeNotifier, MediaType>(GenreTypeNotifier.new);

typedef GenreParams = ({MediaType type, int genreId});

final nowPlayingProvider = FutureProvider.autoDispose<List<MediaItem>>(
  (ref) => ref.watch(mediaRepositoryProvider).getNowPlaying(),
);

final topRatedMoviesProvider = FutureProvider.autoDispose<List<MediaItem>>(
  (ref) => ref.watch(mediaRepositoryProvider).getTopRatedMovies(),
);

final topRatedTvProvider = FutureProvider.autoDispose<List<MediaItem>>(
  (ref) => ref.watch(mediaRepositoryProvider).getTopRatedTv(),
);

final personProvider = FutureProvider.autoDispose.family<Person, int>(
  (ref, id) => ref.watch(mediaRepositoryProvider).getPerson(id),
);
