import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_grid.dart';
import '../providers/search_provider.dart';
import '../widgets/media_grid.dart';

/// Search tab — debounced multi-search over movies and TV shows.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _controller,
              autofocus: false,
              textInputAction: TextInputAction.search,
              onChanged:
                  ref.read(searchQueryProvider.notifier).update,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(query, results),
    );
  }

  Widget _buildBody(String query, AsyncValue results) {
    final l10n = context.l10n;
    if (query.isEmpty) {
      return _Hint(
        icon: Icons.movie_filter_outlined,
        message: l10n.searchPrompt,
      );
    }
    return results.when(
      loading: () => const LoadingGrid(),
      error: (error, _) => ErrorView(
        message: localizeError(l10n, error),
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return _Hint(
            icon: Icons.search_off_rounded,
            message: l10n.searchNoResults(query),
          );
        }
        return MediaGrid(items: items);
      },
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
