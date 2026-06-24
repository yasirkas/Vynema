import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_grid.dart';
import '../../data/models/media_item.dart';
import '../providers/discover_providers.dart';
import '../widgets/media_grid.dart';

class GenreScreen extends ConsumerWidget {
  const GenreScreen({
    super.key,
    required this.mediaType,
    required this.genreId,
    required this.genreName,
  });

  final MediaType mediaType;
  final int genreId;
  final String genreName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (type: mediaType, genreId: genreId);
    final results = ref.watch(discoverByGenreProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: Text(genreName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text(
                mediaType == MediaType.movie ? 'Film' : 'Dizi',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: results.when(
        loading: () => const LoadingGrid(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(discoverByGenreProvider(params)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('İçerik bulunamadı.'));
          }
          return MediaGrid(items: items);
        },
      ),
    );
  }
}
