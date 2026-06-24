import 'media_item.dart';

enum SortBy {
  popularity('popularity.desc'),
  rating('vote_average.desc'),
  newest('primary_release_date.desc');

  const SortBy(this.apiValue);
  final String apiValue;

  String tvApiValue() => this == newest ? 'first_air_date.desc' : apiValue;
}

class DiscoverFilter {
  const DiscoverFilter({
    this.mediaType = MediaType.movie,
    this.sortBy = SortBy.popularity,
    this.minRating = 0,
    this.year,
  });

  final MediaType mediaType;
  final SortBy sortBy;
  final double minRating;
  final int? year;

  String get resolvedSortBy =>
      mediaType == MediaType.tv ? sortBy.tvApiValue() : sortBy.apiValue;
}
