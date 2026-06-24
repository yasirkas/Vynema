import 'media_item.dart';

enum SortBy {
  popularity('popularity.desc', 'Popülariteye Göre'),
  rating('vote_average.desc', 'Puana Göre'),
  newest('primary_release_date.desc', 'En Yeni');

  const SortBy(this.apiValue, this.label);
  final String apiValue;
  final String label;

  String tvApiValue() => this == newest
      ? 'first_air_date.desc'
      : apiValue;
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

  String get screenTitle {
    if (sortBy == SortBy.rating) {
      return mediaType == MediaType.movie ? 'En İyi Filmler' : 'En İyi Diziler';
    }
    if (sortBy == SortBy.newest) {
      return mediaType == MediaType.movie ? 'En Yeni Filmler' : 'En Yeni Diziler';
    }
    return mediaType == MediaType.movie ? 'Popüler Filmler' : 'Popüler Diziler';
  }
}
