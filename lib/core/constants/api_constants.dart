/// TMDB API endpoints and image URL helpers.
///
/// API docs: https://developer.themoviedb.org/reference/intro/getting-started
class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/';

  /// All TMDB content is requested in Turkish per project requirements.
  static const String language = 'tr-TR';

  // --- Endpoints ---
  static const String trendingAll = '/trending/all/week';
  static const String popularMovies = '/movie/popular';
  static const String popularTv = '/tv/popular';
  static const String searchMulti = '/search/multi';

  static String movieDetail(int id) => '/movie/$id';
  static String tvDetail(int id) => '/tv/$id';

  static const String genreMovieList = '/genre/movie/list';
  static const String genreTvList = '/genre/tv/list';
  static const String discoverMovie = '/discover/movie';
  static const String discoverTv = '/discover/tv';

  static String personDetail(int id) => '/person/$id';

  static const String nowPlayingMovies = '/movie/now_playing';
  static const String topRatedMovies = '/movie/top_rated';
  static const String topRatedTv = '/tv/top_rated';

  // --- Image size segments ---
  static const String posterSize = 'w500';
  static const String posterSizeSmall = 'w342';
  static const String backdropSize = 'w780';
  static const String profileSize = 'w185';

  /// Builds a full image URL for a TMDB image [path] (e.g. `/abc.jpg`).
  /// Returns `null` when [path] is null/empty so callers can show a placeholder.
  static String? imageUrl(String? path, {String size = posterSize}) {
    if (path == null || path.isEmpty) return null;
    return '$imageBaseUrl$size$path';
  }
}
