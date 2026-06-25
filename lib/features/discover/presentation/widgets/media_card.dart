import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/media_item.dart';
import 'rating_badge.dart';

/// A poster card for a movie/TV item: image, rating, favorite toggle, title.
///
/// Tapping the card opens the detail screen; pressing scales it down slightly
/// for tactile feedback.
class MediaCard extends ConsumerStatefulWidget {
  const MediaCard({super.key, required this.item});

  final MediaItem item;

  @override
  ConsumerState<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends ConsumerState<MediaCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isFavorite = ref.watch(isFavoriteProvider(item));
    final posterUrl = item.posterUrl(size: ApiConstants.posterSizeSmall);

    return GestureDetector(
      onTap: () => context.goToDetail(item),
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (posterUrl != null)
                        CachedNetworkImage(
                          imageUrl: posterUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 350,
                          filterQuality: FilterQuality.medium,
                          placeholder: (_, _) =>
                              Container(color: AppColors.darkSurfaceVariant),
                          errorWidget: (_, _, _) => const _PosterFallback(),
                        )
                      else
                        const _PosterFallback(),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: RatingBadge(
                          voteAverage: item.voteAverage,
                          compact: true,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: _FavoriteButton(
                          isFavorite: isFavorite,
                          onPressed: () =>
                              ref.read(favoritesProvider.notifier).toggle(item),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (item.year != null)
              Text(
                item.year!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(isFavorite),
          color: isFavorite ? AppColors.secondary : Colors.white,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
      ),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkSurfaceVariant,
      child: const Center(
        child: Icon(Icons.movie_outlined, size: 36, color: Colors.white24),
      ),
    );
  }
}
