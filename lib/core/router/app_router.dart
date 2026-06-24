import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/discover/data/models/media_item.dart';
import '../../features/discover/presentation/screens/detail_screen.dart';
import '../../features/discover/presentation/screens/home_screen.dart';
import '../../features/discover/presentation/screens/search_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../shared/widgets/app_shell.dart';

/// Application route configuration.
///
/// A [StatefulShellRoute] keeps each bottom-nav tab's state alive, with the
/// detail screen pushed on top as a full-screen route.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
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
          final id = int.parse(state.pathParameters['id']!);
          return DetailScreen(mediaType: type, id: id);
        },
      ),
    ],
    navigatorKey: _rootNavigatorKey,
  );
}

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>();

/// Helper to navigate to a media item's detail page from anywhere.
extension MediaNavigation on BuildContext {
  void goToDetail(MediaItem item) =>
      push('/detail/${item.mediaType.asPath}/${item.id}');
}
