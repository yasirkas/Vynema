import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/cast_member.dart';
import '../../data/models/media_detail.dart';
import '../../data/models/media_item.dart';
import '../providers/detail_provider.dart';
import '../widgets/rating_badge.dart';

/// Full detail page for a movie or TV show.
class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.mediaType, required this.id});

  final MediaType mediaType;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(detailProvider(DetailRef(mediaType, id)));

    return Scaffold(
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: ErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(detailProvider(DetailRef(mediaType, id))),
          ),
        ),
        data: (data) => _DetailContent(detail: data),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.detail});

  final MediaDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = detail.toMediaItem();
    final isFavorite = ref.watch(isFavoriteProvider(item));
    final backdropUrl = detail.backdropUrl();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (backdropUrl != null)
                  CachedNetworkImage(
                    imageUrl: backdropUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.darkSurfaceVariant),
                  )
                else
                  Container(color: AppColors.darkSurfaceVariant),
                const DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.posterScrim),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (detail.tagline.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    detail.tagline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                _MetaRow(detail: detail),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isFavorite
                        ? AppColors.secondary
                        : Theme.of(context).colorScheme.primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(item),
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                  ),
                  label: Text(
                    isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                  ),
                ),
                if (detail.genres.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: detail.genres
                        .map((g) => Chip(label: Text(g.name)))
                        .toList(),
                  ),
                ],
                if (detail.overview.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Özet',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.overview,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (detail.cast.isNotEmpty)
          SliverToBoxAdapter(child: _CastSection(cast: detail.cast)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.detail});

  final MediaDetail detail;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      RatingBadge(voteAverage: detail.voteAverage),
      if (detail.year != null) _MetaText(detail.year!),
      if (detail.formattedRuntime != null) _MetaText(detail.formattedRuntime!),
      _MetaText(detail.mediaType == MediaType.movie ? 'Film' : 'Dizi'),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: chips,
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

class _CastSection extends StatelessWidget {
  const _CastSection({required this.cast});

  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Oyuncular',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _CastCard(member: cast[index]),
          ),
        ),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  const _CastCard({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    final url = member.profileUrl();
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.darkSurfaceVariant,
            backgroundImage: url != null ? CachedNetworkImageProvider(url) : null,
            child: url == null
                ? const Icon(Icons.person_rounded, size: 32)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            member.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (member.character.isNotEmpty)
            Text(
              member.character,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }
}
