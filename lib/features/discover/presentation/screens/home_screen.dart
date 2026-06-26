import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart';
import '../../../../core/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/discover_filter.dart';
import '../../data/models/media_item.dart';
import '../providers/discover_providers.dart';
import '../widgets/featured_hero.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/media_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkBackgroundGradient : null,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(trendingProvider);
            ref.invalidate(popularMoviesProvider);
            ref.invalidate(popularTvProvider);
            ref.invalidate(nowPlayingProvider);
            ref.invalidate(topRatedMoviesProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                scrolledUnderElevation: 0,
                flexibleSpace: _FrostedBar(isDark: isDark),
                title: const _BrandTitle(),
                actions: [
                  IconButton(
                    tooltip: l10n.filterTooltip,
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () => _openFilter(context),
                  ),
                  IconButton(
                    tooltip: l10n.settingsTooltip,
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.goToSettings(),
                  ),
                ],
              ),
              // Each section is wrapped in a RepaintBoundary so vertical
              // scrolling just translates a cached layer instead of repainting
              // the carousels (and the genre row's ShaderMask) every frame.
              const SliverToBoxAdapter(
                child: RepaintBoundary(child: _GenreRow()),
              ),
              const SliverToBoxAdapter(
                child: RepaintBoundary(child: FeaturedHero()),
              ),
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: MediaCarousel(
                    title: l10n.carouselNowPlaying,
                    provider: nowPlayingProvider,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: MediaCarousel(
                    title: l10n.carouselTopRated,
                    provider: topRatedMoviesProvider,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: MediaCarousel(
                    title: l10n.titlePopularMovies,
                    provider: popularMoviesProvider,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: MediaCarousel(
                    title: l10n.titlePopularTv,
                    provider: popularTvProvider,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFilter(BuildContext context) async {
    final filter = await FilterBottomSheet.show(
      context,
      initial: const DiscoverFilter(),
    );
    if (filter != null && context.mounted) {
      context.goToDiscover(filter);
    }
  }
}

class _GenreRow extends ConsumerWidget {
  const _GenreRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(genreTypeProvider);
    final genres = ref.watch(genresProvider(type));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GenreTypeToggle(),
        SizedBox(
          height: 40,
          child: genres.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (list) => ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.93, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final genre = list[index];
                  return Center(
                    child: ActionChip(
                      label: Text(genre.name),
                      onPressed: () =>
                          context.goToGenre(type, genre.id, genre.name),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

/// Film / Dizi selector that drives which genre list the row shows and which
/// media type its chips open.
///
/// An animated segmented control: a brand-gradient indicator slides between
/// the two segments, giving it a clear visual hierarchy above the plain genre
/// chips below.
class _GenreTypeToggle extends ConsumerWidget {
  const _GenreTypeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMovie = ref.watch(genreTypeProvider) == MediaType.movie;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Center(
        child: SizedBox(
          width: 200,
          height: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Stack(
                children: [
                  // Sliding gradient indicator behind the selected segment.
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    alignment: isMovie
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _TypeSegment(
                        label: l10n.typeMovie,
                        value: MediaType.movie,
                        selected: isMovie,
                      ),
                      _TypeSegment(
                        label: l10n.typeTv,
                        value: MediaType.tv,
                        selected: !isMovie,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeSegment extends ConsumerWidget {
  const _TypeSegment({
    required this.label,
    required this.value,
    required this.selected,
  });

  final String label;
  final MediaType value;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!selected) ref.read(genreTypeProvider.notifier).set(value);
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13.5,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

/// Solid backdrop for the pinned app bar so it stays clearly visible at all
/// times and never bleeds into the content beneath it.
///
/// Deliberately avoids `BackdropFilter`: a live blur re-samples the scrolling
/// content behind the bar every frame, which janks scrolling on mid-range GPUs
/// (e.g. Adreno 618). An opaque fill gives a clean, always-legible bar at zero
/// GPU cost.
class _FrostedBar extends StatelessWidget {
  const _FrostedBar({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fill = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    // Container (not DecoratedBox) so the fill expands to cover the whole bar;
    // a childless DecoratedBox collapses to zero size and paints nothing,
    // leaving the bar transparent.
    return Container(
      decoration: BoxDecoration(
        color: fill,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.08),
          ),
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.brandGradient.createShader(bounds),
      child: Text(
        context.l10n.appTitle,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
