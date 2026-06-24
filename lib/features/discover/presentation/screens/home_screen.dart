import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
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
