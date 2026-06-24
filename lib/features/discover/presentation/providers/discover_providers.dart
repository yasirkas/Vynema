import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/models/media_item.dart';

/// Trending movies & TV for the week.
final trendingProvider = FutureProvider.autoDispose<List<MediaItem>>(
  (ref) => ref.watch(mediaRepositoryProvider).getTrending(),
);

/// Popular movies.
final popularMoviesProvider = FutureProvider.autoDispose<List<MediaItem>>(
  (ref) => ref.watch(mediaRepositoryProvider).getPopularMovies(),
);

/// Popular TV shows.
final popularTvProvider = FutureProvider.autoDispose<List<MediaItem>>(
  (ref) => ref.watch(mediaRepositoryProvider).getPopularTv(),
);
