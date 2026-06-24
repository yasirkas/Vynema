import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized access to environment configuration loaded from `.env`.
///
/// The TMDB API key is never hard-coded; it is read at runtime so it can be
/// kept out of version control (see `.gitignore`).
class AppEnv {
  const AppEnv._();

  /// TMDB API key (v3 auth). Empty when the user has not configured `.env`.
  static String get tmdbApiKey => dotenv.maybeGet('TMDB_API_KEY') ?? '';

  /// Whether a non-empty API key has been provided.
  static bool get hasApiKey => tmdbApiKey.trim().isNotEmpty;
}
