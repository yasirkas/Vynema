import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_grid.dart';
import '../../data/models/discover_filter.dart';
import '../../data/models/media_item.dart';
import '../discover_l10n.dart';
import '../widgets/media_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key, required this.filter});

  final DiscoverFilter filter;

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final List<MediaItem> _items = [];
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);

  int _page = 0;
  bool _hasMore = true;
  bool _inFlight = false;
  Object? _error;

  DiscoverFilter get _f => widget.filter;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _loadingNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_inFlight || !_hasMore) return;
    _inFlight = true;
    _loadingNotifier.value = true;
    try {
      final result = await ref.read(mediaRepositoryProvider).discoverItems(
            type: _f.mediaType,
            sortBy: _f.resolvedSortBy,
            minRating: _f.minRating > 0 ? _f.minRating : null,
            year: _f.year,
            page: _page + 1,
          );
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _page++;
        _hasMore = result.hasMore;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      _inFlight = false;
      if (mounted) _loadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(discoverScreenTitle(context.l10n, _f))),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_items.isEmpty) {
      return ValueListenableBuilder(
        valueListenable: _loadingNotifier,
        builder: (context, loading, _) {
          if (loading) return const LoadingGrid();
          if (_error != null) {
            return ErrorView(
              message: localizeError(context.l10n, _error!),
              onRetry: _loadMore,
            );
          }
          return const SizedBox.shrink();
        },
      );
    }
    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => RepaintBoundary(
                child: MediaCard(item: _items[index]),
              ),
              childCount: _items.length,
              addRepaintBoundaries: false,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.52,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ValueListenableBuilder(
            valueListenable: _loadingNotifier,
            builder: (context, loading, _) => loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox(height: 24),
          ),
        ),
      ],
    );
  }
}
