import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/loading_grid.dart';
import '../../data/models/media_item.dart';
import 'media_card.dart';
import 'section_header.dart';

/// A titled, horizontally-scrolling row of [MediaCard]s driven by an async
/// provider. Handles loading, error and empty states inline.
class MediaCarousel extends ConsumerWidget {
  const MediaCarousel({
    super.key,
    required this.title,
    required this.provider,
    this.height = 230,
  });

  final String title;
  final FutureProvider<List<MediaItem>> provider;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        asyncItems.when(
          loading: () => LoadingRow(height: height),
          error: (error, _) => SizedBox(
            height: height,
            child: ErrorView(message: localizeError(context.l10n, error)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return SizedBox(
                height: height,
                child: Center(child: Text(context.l10n.emptyContent)),
              );
            }
            return SizedBox(
              height: height,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => FadeSlideIn(
                  delay: staggerDelay(index),
                  child: SizedBox(
                    width: height * 0.66,
                    child: MediaCard(item: items[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
