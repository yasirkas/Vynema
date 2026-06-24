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
