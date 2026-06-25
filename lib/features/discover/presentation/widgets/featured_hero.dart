import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/media_item.dart';
import '../providers/discover_providers.dart';
import 'rating_badge.dart';

const int _kHeroCount = 5;
const Duration _kAutoAdvance = Duration(seconds: 6);

/// Full-bleed, auto-advancing showcase of the top trending titles shown at the
/// top of the home screen. Each page is a cinematic backdrop with a gradient
/// scrim, title, rating and a call-to-action.
class FeaturedHero extends ConsumerStatefulWidget {
  const FeaturedHero({super.key});

  @override
  ConsumerState<FeaturedHero> createState() => _FeaturedHeroState();
}

class _FeaturedHeroState extends ConsumerState<FeaturedHero> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;
  int _itemCount = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoAdvance(int count) {
    if (_itemCount == count) return;
    _itemCount = count;
    _timer?.cancel();
    if (count <= 1) return;
    _timer = Timer.periodic(_kAutoAdvance, (_) {
      if (!_controller.hasClients) return;
      final next = (_page + 1) % count;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(trendingProvider);

    return asyncItems.when(
      loading: () => const _HeroPlaceholder(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        final featured =
            items.where((i) => i.backdropPath != null).take(_kHeroCount).toList();
        if (featured.isEmpty) return const SizedBox.shrink();
        _startAutoAdvance(featured.length);

        // Backdrops are 16:9 — size the image area to that ratio so artwork is
        // shown in full with no cropping; the caption sits below it.
        final width = MediaQuery.sizeOf(context).width;
        final backdropHeight = width * 9 / 16;
        const captionHeight = 100.0;

        return SizedBox(
          height: backdropHeight + captionHeight,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: featured.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _HeroSlide(
                  item: featured[i],
                  backdropHeight: backdropHeight,
                ),
              ),
              Positioned(
                top: backdropHeight - 18,
                left: 0,
                right: 0,
                child: _Dots(count: featured.length, active: _page),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroSlide extends ConsumerWidget {
  const _HeroSlide({required this.item, required this.backdropHeight});

  final MediaItem item;
  final double backdropHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(item));
    final backdropUrl = item.backdropUrl();

    return GestureDetector(
      onTap: () => context.goToDetail(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full 16:9 artwork — shown complete, never cropped.
          SizedBox(
            height: backdropHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (backdropUrl != null)
                  CachedNetworkImage(
                    imageUrl: backdropUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 780,
                    placeholder: (_, _) =>
                        Container(color: AppColors.darkSurfaceVariant),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.darkSurfaceVariant),
                  )
                else
                  Container(color: AppColors.darkSurfaceVariant),
                // Subtle bottom fade so the artwork blends into the caption.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xFF0B0B12)],
                      stops: [0.78, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingBadge(voteAverage: item.voteAverage),
                    if (item.year != null) ...[
                      const SizedBox(width: 10),
                      Text(
                        item.year!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const Spacer(),
                    _HeroFavoriteButton(
                      isFavorite: isFavorite,
                      onPressed: () =>
                          ref.read(favoritesProvider.notifier).toggle(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFavoriteButton extends StatelessWidget {
  const _HeroFavoriteButton({
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              color: isFavorite
                  ? AppColors.secondary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    final backdropHeight = MediaQuery.sizeOf(context).width * 9 / 16;
    return Container(
      height: backdropHeight + 100,
      color: AppColors.darkSurfaceVariant,
    );
  }
}