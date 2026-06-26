import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';

/// Hosts the shell branches in a [PageView] so the main tabs can be switched by
/// swiping left/right, kept in sync with the bottom navigation bar.
///
/// Swiping drives [StatefulNavigationShell.goBranch]; tapping a tab animates
/// the page across. Branch state is preserved by the shell, so revisiting a tab
/// restores its previous scroll position and navigation stack.
class SwipeableTabView extends StatefulWidget {
  const SwipeableTabView({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<SwipeableTabView> createState() => _SwipeableTabViewState();
}

class _SwipeableTabViewState extends State<SwipeableTabView> {
  late final PageController _controller =
      PageController(initialPage: widget.navigationShell.currentIndex);

  @override
  void didUpdateWidget(SwipeableTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Bottom-nav tap (or any external branch change) animates the page across.
    final index = widget.navigationShell.currentIndex;
    if (_controller.hasClients && _controller.page?.round() != index) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      onPageChanged: (index) => widget.navigationShell.goBranch(index),
      children: widget.children,
    );
  }
}

/// Bottom-navigation scaffold wrapping the three main tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Re-tapping the active tab pops to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: l10n.navDiscover,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search_rounded),
            label: l10n.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline_rounded),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: l10n.navFavorites,
          ),
        ],
      ),
    );
  }
}
