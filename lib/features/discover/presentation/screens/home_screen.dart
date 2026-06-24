import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart';
import '../../../../core/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/discover_filter.dart';
import '../../data/models/media_item.dart';
import '../providers/discover_providers.dart';
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
                floating: true,
                backgroundColor: Colors.transparent,
                title: const _BrandTitle(),
                actions: [
                  IconButton(
                    tooltip: l10n.filterTooltip,
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () => _openFilter(context),
                  ),
                  IconButton(
                    tooltip: l10n.themeToggleTooltip,
                    onPressed: () =>
                        ref.read(themeModeProvider.notifier).toggle(),
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.settingsTooltip,
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.goToSettings(),
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: _GenreRow()),
              SliverToBoxAdapter(
                child: MediaCarousel(
                  title: l10n.carouselTrending,
                  provider: trendingProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: MediaCarousel(
                  title: l10n.carouselNowPlaying,
                  provider: nowPlayingProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: MediaCarousel(
                  title: l10n.titlePopularMovies,
                  provider: popularMoviesProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: MediaCarousel(
                  title: l10n.carouselTopRated,
                  provider: topRatedMoviesProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: MediaCarousel(
                  title: l10n.titlePopularTv,
                  provider: popularTvProvider,
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
    final genres = ref.watch(genresProvider(MediaType.movie));
    return genres.when(
      loading: () => const SizedBox(height: 48),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) => SizedBox(
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final genre = list[index];
            return ActionChip(
              label: Text(genre.name),
              onPressed: () => context.goToGenre(
                MediaType.movie,
                genre.id,
                genre.name,
              ),
            );
          },
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
      shaderCallback: (bounds) =>
          AppColors.brandGradient.createShader(bounds),
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
