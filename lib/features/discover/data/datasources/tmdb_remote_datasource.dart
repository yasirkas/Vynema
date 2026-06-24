import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/genre.dart';
import '../models/media_detail.dart';
import '../models/media_item.dart';
import '../models/person.dart';

/// Talks to the TMDB REST API and maps responses into domain models.
class TmdbRemoteDataSource {
  TmdbRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<MediaItem>> getTrending() =>
      _fetchList(ApiConstants.trendingAll);

  Future<List<MediaItem>> getPopularMovies() =>
      _fetchList(ApiConstants.popularMovies, fallbackType: MediaType.movie);

  Future<List<MediaItem>> getPopularTv() =>
      _fetchList(ApiConstants.popularTv, fallbackType: MediaType.tv);

  /// Searches movies and TV shows; `person` results are filtered out.
  Future<List<MediaItem>> searchMulti(String query) {
    return _fetchList(
      ApiConstants.searchMulti,
      queryParameters: {'query': query, 'include_adult': false},
    );
  }

  Future<List<MediaItem>> getNowPlaying() =>
      _fetchList(ApiConstants.nowPlayingMovies, fallbackType: MediaType.movie);

  Future<List<MediaItem>> getTopRatedMovies() =>
      _fetchList(ApiConstants.topRatedMovies, fallbackType: MediaType.movie);

  Future<List<MediaItem>> getTopRatedTv() =>
      _fetchList(ApiConstants.topRatedTv, fallbackType: MediaType.tv);

  Future<({List<MediaItem> items, bool hasMore})> discoverItems({
    required MediaType type,
    String sortBy = 'popularity.desc',
    double? minRating,
    int? year,
    int page = 1,
  }) async {
    final path = type == MediaType.movie
        ? ApiConstants.discoverMovie
        : ApiConstants.discoverTv;
    final params = <String, dynamic>{'sort_by': sortBy, 'page': page};
    if (minRating != null && minRating > 0) {
      params['vote_average.gte'] = minRating;
      params['vote_count.gte'] = 50;
    }
    if (year != null) {
      params[type == MediaType.movie
          ? 'primary_release_year'
          : 'first_air_date_year'] = year;
    }
    try {
      final response = await _dio.get(path, queryParameters: params);
      final totalPages = (response.data['total_pages'] as int?) ?? 1;
      final results = (response.data['results'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .take(18)
          .map((j) => MediaItem.fromJson(j, fallbackType: type))
          .toList();
      return (items: results, hasMore: page < totalPages);
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'İçerik yüklenemedi.');
    }
  }

  Future<List<Genre>> getGenres(MediaType type) async {
    final path = type == MediaType.movie
        ? ApiConstants.genreMovieList
        : ApiConstants.genreTvList;
    try {
      final response = await _dio.get(path);
      final list = (response.data['genres'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      return list.map(Genre.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Türler yüklenemedi.');
    }
  }

  Future<({List<MediaItem> items, bool hasMore})> discoverByGenre(
    MediaType type,
    int genreId, {
    int page = 1,
  }) async {
    final path = type == MediaType.movie
        ? ApiConstants.discoverMovie
        : ApiConstants.discoverTv;
    try {
      final response = await _dio.get(path, queryParameters: {
        'with_genres': genreId,
        'sort_by': 'popularity.desc',
        'page': page,
      });
      final totalPages = (response.data['total_pages'] as int?) ?? 1;
      final results = (response.data['results'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .take(18)
          .map((json) => MediaItem.fromJson(json, fallbackType: type))
          .toList();
      return (items: results, hasMore: page < totalPages);
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'İçerik yüklenemedi.');
    }
  }

  Future<Person> getPerson(int id) async {
    try {
      final response = await _dio.get(
        ApiConstants.personDetail(id),
        queryParameters: {'append_to_response': 'combined_credits'},
      );
      return Person.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Kişi yüklenemedi.');
    }
  }

  Future<MediaDetail> getDetail(MediaType type, int id) async {
    final path = type == MediaType.movie
        ? ApiConstants.movieDetail(id)
        : ApiConstants.tvDetail(id);
    try {
      final response = await _dio.get(
        path,
        queryParameters: {
          'append_to_response': 'credits,videos,similar,watch/providers',
        },
      );
      return MediaDetail.fromJson(
        response.data as Map<String, dynamic>,
        mediaType: type,
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'İçerik yüklenemedi.');
    }
  }

  Future<List<MediaItem>> _fetchList(
    String path, {
    MediaType? fallbackType,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await _dio.get(path, queryParameters: queryParameters);
      final results = (response.data['results'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      return results
          // Skip people and any entry that can't be rendered as a card.
          .where((json) => json['media_type'] != 'person')
          .map((json) =>
              MediaItem.fromJson(json, fallbackType: fallbackType))
          .toList();
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'İçerik yüklenemedi.');
    }
  }
}
