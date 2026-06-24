import '../../../l10n/app_localizations.dart';
import '../data/models/discover_filter.dart';
import '../data/models/media_item.dart';

/// Localized label for a [SortBy] option.
String sortByLabel(AppLocalizations l10n, SortBy sort) => switch (sort) {
      SortBy.popularity => l10n.sortPopularity,
      SortBy.rating => l10n.sortRating,
      SortBy.newest => l10n.sortNewest,
    };

/// Localized screen title for a [DiscoverFilter] (sort + media type).
String discoverScreenTitle(AppLocalizations l10n, DiscoverFilter filter) {
  final isMovie = filter.mediaType == MediaType.movie;
  return switch (filter.sortBy) {
    SortBy.rating => isMovie ? l10n.titleTopMovies : l10n.titleTopTv,
    SortBy.newest => isMovie ? l10n.titleNewestMovies : l10n.titleNewestTv,
    SortBy.popularity => isMovie ? l10n.titlePopularMovies : l10n.titlePopularTv,
  };
}
