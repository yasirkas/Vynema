import 'package:flutter/material.dart';

import '../../../../shared/widgets/fade_slide_in.dart';
import '../../data/models/media_item.dart';
import 'media_card.dart';

/// A scrollable 3-column grid of [MediaCard]s, reused by search and favorites.
class MediaGrid extends StatelessWidget {
  const MediaGrid({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
  });

  final List<MediaItem> items;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => FadeSlideIn(
        delay: staggerDelay(index),
        child: MediaCard(item: items[index]),
      ),
    );
  }
}
