import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/media_detail.dart';
import '../models/media_item.dart';

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

  Future<MediaDetail> getDetail(MediaType type, int id) async {
    final path = type == MediaType.movie
        ? ApiConstants.movieDetail(id)
        : ApiConstants.tvDetail(id);
    try {
      final response = await _dio.get(
        path,
        queryParameters: {'append_to_response': 'credits'},
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
