import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/network/connectivity.dart';
import '../../features/discover/presentation/providers/detail_provider.dart';
import '../../features/discover/presentation/providers/discover_providers.dart';
import '../../features/discover/presentation/providers/search_provider.dart';

/// How long the green "back online" confirmation stays before sliding away.
const Duration _kReconnectedDuration = Duration(seconds: 3);

/// What the top connectivity banner is currently showing.
enum _BannerMode { hidden, offline, reconnected }

/// Wraps the whole app: shows a top offline banner whenever the device loses
/// its connection, a brief "back online" banner when it returns, and refetches
/// content automatically on reconnect.
///
/// The provider-driven screens (home, search, detail, person, genre lists)
/// cache an [AsyncError] once a request fails offline and would otherwise stay
/// broken until a manual pull-to-refresh; invalidating them on reconnect makes
/// the content reload on its own.
class ConnectivityScope extends ConsumerStatefulWidget {
  const ConnectivityScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ConnectivityScope> createState() => _ConnectivityScopeState();
}

class _ConnectivityScopeState extends ConsumerState<ConnectivityScope> {
  _BannerMode _mode = _BannerMode.hidden;
  Timer? _reconnectedTimer;

  @override
  void dispose() {
    _reconnectedTimer?.cancel();
    super.dispose();
  }

  void _onConnectivityChange(bool wasOnline, bool isOnline) {
    if (!isOnline) {
      _reconnectedTimer?.cancel();
      setState(() => _mode = _BannerMode.offline);
      return;
    }
    // Came back online from a confirmed offline state: refetch and confirm.
    if (!wasOnline) {
      _refetchContent();
      setState(() => _mode = _BannerMode.reconnected);
      _reconnectedTimer?.cancel();
      _reconnectedTimer = Timer(_kReconnectedDuration, () {
        if (mounted) setState(() => _mode = _BannerMode.hidden);
      });
    }
  }

  /// Invalidates every content provider so the active screen refetches with the
  /// restored connection. Invalidating a family (no argument) clears all of its
  /// instances; auto-dispose providers that aren't currently watched are
  /// already gone, so this is a no-op for them.
  void _refetchContent() {
    ref.invalidate(trendingProvider);
    ref.invalidate(popularMoviesProvider);
    ref.invalidate(popularTvProvider);
    ref.invalidate(nowPlayingProvider);
    ref.invalidate(topRatedMoviesProvider);
    ref.invalidate(topRatedTvProvider);
    ref.invalidate(genresProvider);
    ref.invalidate(personProvider);
    ref.invalidate(detailProvider);
    ref.invalidate(searchResultsProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectivityProvider, (prev, next) {
      final wasOnline = prev?.asData?.value ?? true;
      final isOnline = next.asData?.value ?? true;
      _onConnectivityChange(wasOnline, isOnline);
    });

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _ConnectivityBanner(mode: _mode),
        ),
      ],
    );
  }
}

/// Slides down from the top edge while offline / just-reconnected and tucks
/// away otherwise. Red for offline, green for the reconnect confirmation.
class _ConnectivityBanner extends StatelessWidget {
  const _ConnectivityBanner({required this.mode});

  final _BannerMode mode;

  @override
  Widget build(BuildContext context) {
    final visible = mode != _BannerMode.hidden;
    final isOffline = mode == _BannerMode.offline;
    final color = isOffline ? const Color(0xFFB00020) : const Color(0xFF1B873F);
    final icon = isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded;
    final label =
        isOffline ? context.l10n.offlineBanner : context.l10n.onlineBanner;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        offset: visible ? Offset.zero : const Offset(0, -1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: visible ? 1 : 0,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                color: color,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
