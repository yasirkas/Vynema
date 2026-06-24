import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/media_item.dart';
import '../providers/discover_providers.dart';
import '../widgets/media_carousel.dart';

/// Discover tab — trending and popular carousels.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

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
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: const _BrandTitle(),
                actions: [
                  IconButton(
                    tooltip: 'Tema değiştir',
                    onPressed: () =>
                        ref.read(themeModeProvider.notifier).toggle(),
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: _GenreRow()),
              SliverToBoxAdapter(
                child: MediaCarousel(
                  title: 'Bu Hafta Trend',
                  provider: trendingProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: MediaCarousel(
                  title: 'Popüler Filmler',
                  provider: popularMoviesProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: MediaCarousel(
                  title: 'Popüler Diziler',
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
        'Vynema',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
