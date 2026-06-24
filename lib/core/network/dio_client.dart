import 'package:dio/dio.dart';

import '../config/env.dart';
import '../constants/api_constants.dart';

/// Thrown when a TMDB request fails, carrying a user-friendly Turkish message.
class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Builds a configured [Dio] instance for the TMDB API.
///
/// An interceptor automatically appends the API key and language to every
/// request, so feature code never touches the key directly.
Dio createDioClient() {
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
          () => ApiConstants.language,
        );
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error.copyWith(message: _messageFor(error)));
      },
    ),
  );

  return dio;
}

String _messageFor(DioException error) {
  if (!AppEnv.hasApiKey) {
    return 'TMDB API anahtarı bulunamadı. Lütfen .env dosyasına anahtarınızı ekleyin.';
  }
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
    case DioExceptionType.connectionError:
      return 'İnternet bağlantısı yok. Bağlantınızı kontrol edin.';
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      if (code == 401) {
        return 'API anahtarı geçersiz. .env dosyasındaki anahtarı kontrol edin.';
      }
      return 'Sunucu hatası ($code). Lütfen daha sonra tekrar deneyin.';
    default:
      return 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
