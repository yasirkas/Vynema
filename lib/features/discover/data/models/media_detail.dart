import '../../../../core/constants/api_constants.dart';
import 'cast_member.dart';
import 'genre.dart';
import 'media_item.dart';
import 'watch_provider.dart';

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
    required this.trailerKey,
    required this.similar,
    required this.watchProviders,
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
  final String? trailerKey;
  final List<MediaItem> similar;
  final List<WatchProvider> watchProviders;

  String? posterUrl({String size = ApiConstants.posterSize}) =>
      ApiConstants.imageUrl(posterPath, size: size);

  String? backdropUrl({String size = ApiConstants.backdropSize}) =>
      ApiConstants.imageUrl(backdropPath, size: size);

  String? get year {
    if (releaseDate == null || releaseDate!.length < 4) return null;
    return releaseDate!.substring(0, 4);
  }

  String? get formattedRuntime {
    final r = runtimeMinutes;
    if (r == null || r <= 0) return null;
    final h = r ~/ 60;
    final m = r % 60;
    if (h > 0) return '${h}s ${m}dk';
    return '${m}dk';
  }

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

    final castJson = (json['credits']?['cast'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final cast = castJson.take(20).map(CastMember.fromJson).toList();

    // Trailer: first YouTube Trailer, fall back to first YouTube video.
    final videoResults = (json['videos']?['results'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final trailer = videoResults.where(
      (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
    ).firstOrNull;
    final trailerKey = (trailer ?? videoResults.where((v) => v['site'] == 'YouTube').firstOrNull)
        ?['key'] as String?;

    // Similar content (first 12).
    final similar = (json['similar']?['results'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .take(12)
        .map((j) => MediaItem.fromJson(j, fallbackType: mediaType))
        .toList();

    // Watch providers: TR first, US fallback, flatrate only.
    final providerResults =
        json['watch/providers']?['results'] as Map<String, dynamic>?;
    List<WatchProvider> watchProviders = [];
    if (providerResults != null) {
      final region = (providerResults['TR'] ?? providerResults['US'])
          as Map<String, dynamic>?;
      if (region != null) {
        watchProviders = (region['flatrate'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map(WatchProvider.fromJson)
            .toList();
      }
    }

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
      trailerKey: trailerKey,
      similar: similar,
      watchProviders: watchProviders,
    );
  }
}
