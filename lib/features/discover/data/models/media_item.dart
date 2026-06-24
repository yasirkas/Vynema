import '../../../../core/constants/api_constants.dart';

/// The kind of media an item represents.
enum MediaType {
  movie,
  tv;

  /// Path segment used in routes and TMDB endpoints (`movie` / `tv`).
  String get asPath => name;

  static MediaType fromString(String? value) =>
      value == 'tv' ? MediaType.tv : MediaType.movie;
}

/// Unified summary model for a movie or TV show.
///
/// TMDB's `/search/multi` and `/trending` endpoints mix both types, so a single
/// model lets the UI render cards and grids without branching.
class MediaItem {
  const MediaItem({
    required this.id,
    required this.mediaType,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  final int id;
  final MediaType mediaType;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;

  /// Full poster URL (or null → caller shows a placeholder).
  String? posterUrl({String size = ApiConstants.posterSize}) =>
      ApiConstants.imageUrl(posterPath, size: size);

  /// Full backdrop URL (or null).
  String? backdropUrl({String size = ApiConstants.backdropSize}) =>
      ApiConstants.imageUrl(backdropPath, size: size);

  /// Year extracted from the release/air date, e.g. "2024".
  String? get year {
    if (releaseDate == null || releaseDate!.length < 4) return null;
    return releaseDate!.substring(0, 4);
  }

  /// Parses an item from a TMDB JSON map.
  ///
  /// [fallbackType] is used when the payload omits `media_type` (e.g. the
  /// `/movie/popular` and `/tv/popular` endpoints).
  factory MediaItem.fromJson(
    Map<String, dynamic> json, {
    MediaType? fallbackType,
  }) {
    final rawType = json['media_type'] as String?;
    final type = rawType != null
        ? MediaType.fromString(rawType)
        : (fallbackType ?? MediaType.movie);

    // Movies use `title`/`release_date`; TV shows use `name`/`first_air_date`.
    final title = (json['title'] ?? json['name'] ?? '') as String;
    final date = (json['release_date'] ?? json['first_air_date']) as String?;

    return MediaItem(
      id: json['id'] as int,
      mediaType: type,
      title: title,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: date,
    );
  }

  /// Serializes to a JSON map for local persistence (favorites in Hive).
  Map<String, dynamic> toJson() => {
        'id': id,
        'media_type': mediaType.asPath,
        'title': title,
        'overview': overview,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'vote_average': voteAverage,
        'release_date': releaseDate,
      };

  @override
  bool operator ==(Object other) =>
      other is MediaItem &&
      other.id == id &&
      other.mediaType == mediaType;

  @override
  int get hashCode => Object.hash(id, mediaType);
}
