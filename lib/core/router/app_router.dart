import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/discover/data/models/media_item.dart';
import '../../features/discover/data/models/discover_filter.dart';
import '../../features/discover/presentation/screens/detail_screen.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/discover/presentation/screens/genre_screen.dart';
import '../../features/discover/presentation/screens/home_screen.dart';
import '../../features/discover/presentation/screens/person_screen.dart';
import '../../features/discover/presentation/screens/search_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../l10n.dart';
import '../theme/app_colors.dart';

/// Application route configuration.
///
/// A [StatefulShellRoute] keeps each bottom-nav tab's state alive, with the
/// detail screen pushed on top as a full-screen route.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/detail/:type/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final type = MediaType.fromString(state.pathParameters['type']);
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const _NotFoundScreen();
          return DetailScreen(mediaType: type, id: id);
        },
      ),
      GoRoute(
        path: '/discover',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => DiscoverScreen(
          filter: state.extra! as DiscoverFilter,
        ),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/person/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const _NotFoundScreen();
          return PersonScreen(personId: id);
        },
      ),
      GoRoute(
        path: '/genre',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra! as Map<String, dynamic>;
          return GenreScreen(
            mediaType: extra['type'] as MediaType,
            genreId: extra['genreId'] as int,
            genreName: extra['genreName'] as String,
          );
        },
      ),
    ],
    navigatorKey: _rootNavigatorKey,
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );
}

/// Shown when a route can't be resolved (e.g. a malformed deep link with a
/// non-numeric id, or an unknown path). Carries the Vynema brand so the
/// fallback still feels like part of the app rather than a dead end.
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkBackgroundGradient : null,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.brandGradient.createShader(bounds),
                  child: Text(
                    context.l10n.appTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Icon(
                  Icons.movie_filter_outlined,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.brandGradient.createShader(bounds),
                  child: Text(
                    '404',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.emptyContent,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_rounded),
                  label: Text(context.l10n.goHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>();

extension MediaNavigation on BuildContext {
  void goToDetail(MediaItem item) =>
      push('/detail/${item.mediaType.asPath}/${item.id}');

  void goToGenre(MediaType type, int genreId, String genreName) => push(
        '/genre',
        extra: {'type': type, 'genreId': genreId, 'genreName': genreName},
      );

  void goToPerson(int personId) => push('/person/$personId');

  void goToDiscover(DiscoverFilter filter) =>
      push('/discover', extra: filter);

  void goToSettings() => push('/settings');
}
