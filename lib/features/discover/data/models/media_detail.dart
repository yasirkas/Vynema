import '../../../../core/constants/api_constants.dart';
import 'cast_member.dart';
import 'genre.dart';
import 'media_item.dart';

/// Full detail for a movie or TV show, including genres and top cast.
class MediaDetail {
  const MediaDetail({
    required this.id,
    required this.mediaType,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.runtimeMinutes,
    required this.tagline,
    required this.genres,
    required this.cast,
  });

  final int id;
  final MediaType mediaType;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final int? runtimeMinutes;
  final String tagline;
  final List<Genre> genres;
  final List<CastMember> cast;

  String? posterUrl({String size = ApiConstants.posterSize}) =>
      ApiConstants.imageUrl(posterPath, size: size);

  String? backdropUrl({String size = ApiConstants.backdropSize}) =>
      ApiConstants.imageUrl(backdropPath, size: size);

  String? get year {
    if (releaseDate == null || releaseDate!.length < 4) return null;
    return releaseDate!.substring(0, 4);
  }

  /// Human-readable runtime, e.g. "2s 14dk", or null when unknown.
  String? get formattedRuntime {
    final r = runtimeMinutes;
    if (r == null || r <= 0) return null;
    final h = r ~/ 60;
    final m = r % 60;
    if (h > 0) return '${h}s ${m}dk';
    return '${m}dk';
  }

  /// Builds a lightweight [MediaItem] (used for favorite toggling on detail).
  MediaItem toMediaItem() => MediaItem(
        id: id,
        mediaType: mediaType,
        title: title,
        overview: overview,
        posterPath: posterPath,
        backdropPath: backdropPath,
        voteAverage: voteAverage,
        releaseDate: releaseDate,
      );

  factory MediaDetail.fromJson(
    Map<String, dynamic> json, {
    required MediaType mediaType,
  }) {
    final title = (json['title'] ?? json['name'] ?? '') as String;
    final date = (json['release_date'] ?? json['first_air_date']) as String?;

    // Movies expose `runtime`; TV shows expose `episode_run_time` (a list).
    int? runtime = (json['runtime'] as num?)?.toInt();
    if (runtime == null) {
      final episodeRuntimes = json['episode_run_time'] as List<dynamic>?;
      if (episodeRuntimes != null && episodeRuntimes.isNotEmpty) {
        runtime = (episodeRuntimes.first as num).toInt();
      }
    }

    final genres = (json['genres'] as List<dynamic>? ?? [])
        .map((g) => Genre.fromJson(g as Map<String, dynamic>))
        .toList();

    final castJson =
        (json['credits']?['cast'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final cast =
        castJson.take(20).map(CastMember.fromJson).toList();

    return MediaDetail(
      id: json['id'] as int,
      mediaType: mediaType,
      title: title,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      releaseDate: date,
      runtimeMinutes: runtime,
      tagline: (json['tagline'] ?? '') as String,
      genres: genres,
      cast: cast,
    );
  }
}
