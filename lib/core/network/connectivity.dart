import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits whether the device currently has a network connection.
///
/// Seeded with an immediate check so the value is correct on first build, then
/// follows [Connectivity.onConnectivityChanged]. This reflects the device's
/// network interfaces, not reachability of TMDB — good enough to surface an
/// offline banner and to trigger a refetch when connectivity returns.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _isOnline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_isOnline);
});

/// True when at least one active connection type is present.
bool _isOnline(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);
