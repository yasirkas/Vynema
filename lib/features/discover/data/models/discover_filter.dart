import 'media_item.dart';

enum SortBy {
  popularity('popularity.desc'),
  rating('vote_average.desc'),
  upcoming('primary_release_date.asc'),
  recentlyReleased('primary_release_date.desc');

  const SortBy(this.apiValue);
  final String apiValue;

  String tvApiValue() => switch (this) {
        SortBy.upcoming => 'first_air_date.asc',
        SortBy.recentlyReleased => 'first_air_date.desc',
        _ => apiValue,
      };
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

  bool get usesDedicatedEndpoint =>
      sortBy == SortBy.upcoming || sortBy == SortBy.recentlyReleased;
}
