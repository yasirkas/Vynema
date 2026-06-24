import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/models/media_item.dart';

/// The current search query text.
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  /// Updates the query, debouncing rapid keystrokes (350ms).
  void update(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      state = value.trim();
    });
  }

  void clear() {
    _debounce?.cancel();
    state = '';
  }
}

/// Search results for the current (debounced) query.
///
/// Returns an empty list for an empty query so the UI shows the idle state
/// instead of issuing a request.
final searchResultsProvider =
    FutureProvider.autoDispose<List<MediaItem>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  return ref.watch(mediaRepositoryProvider).search(query);
});
