import 'package:dio/dio.dart';

import '../config/env.dart';
import '../constants/api_constants.dart';

/// Categorizes a TMDB request failure so the UI can show a localized message.
enum ApiErrorKind {
  noApiKey,
  timeout,
  noConnection,
  invalidApiKey,
  server,
  unknown,
}

/// Thrown when a TMDB request fails.
///
/// Carries a language-agnostic [kind] (and optional HTTP [statusCode]); the
/// presentation layer turns it into a localized message at display time.
class ApiException implements Exception {
  ApiException(this.kind, {this.statusCode});

  final ApiErrorKind kind;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(${kind.name}${statusCode != null ? ', $statusCode' : ''})';
}

/// Builds a configured [Dio] instance for the TMDB API.
///
/// An interceptor automatically appends the API key and language to every
/// request, so feature code never touches the key directly. [languageTag] sets
/// the TMDB `language` query value (e.g. `tr-TR`, `en-US`).
Dio createDioClient({String languageTag = ApiConstants.language}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters.putIfAbsent(
          'api_key',
          () => AppEnv.tmdbApiKey,
        );
        options.queryParameters.putIfAbsent(
          'language',
          () => languageTag,
        );
        handler.next(options);
      },
    ),
  );

  return dio;
}

/// Classifies a [DioException] into an [ApiErrorKind].
ApiErrorKind apiErrorKindFor(DioException error) {
  if (!AppEnv.hasApiKey) return ApiErrorKind.noApiKey;
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return ApiErrorKind.timeout;
    case DioExceptionType.connectionError:
      return ApiErrorKind.noConnection;
    case DioExceptionType.badResponse:
      return error.response?.statusCode == 401
          ? ApiErrorKind.invalidApiKey
          : ApiErrorKind.server;
    default:
      return ApiErrorKind.unknown;
  }
}
