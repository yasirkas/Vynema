import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../data/models/media_item.dart';
import '../../data/models/person.dart';
import '../providers/discover_providers.dart';
import '../widgets/media_card.dart';

class PersonScreen extends ConsumerWidget {
  const PersonScreen({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(personProvider(personId));

    return Scaffold(
      body: person.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(personProvider(personId)),
          ),
        ),
        data: (p) => _PersonContent(person: p),
      ),
    );
  }
}

class _PersonContent extends StatelessWidget {
  const _PersonContent({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final profileUrl = person.profileUrl(size: 'h632');

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(person.name),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: profileUrl != null
                      ? CachedNetworkImage(
                          imageUrl: profileUrl,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          memCacheWidth: 240,
                        )
                      : Container(
                          width: 120,
                          height: 180,
                          color: AppColors.darkSurfaceVariant,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: Colors.white24,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (person.knownForDepartment.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _departmentLabel(person.knownForDepartment),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                      if (person.birthYear != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.cake_outlined, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              person.birthYear!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                      if (person.placeOfBirth != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                person.placeOfBirth!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (person.biography.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biyografi',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _ExpandableBio(bio: person.biography),
                ],
              ),
            ),
          ),
        if (person.credits.isNotEmpty)
          SliverToBoxAdapter(
            child: _CreditsSection(
              credits: person.credits,
              name: person.name,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  String _departmentLabel(String dept) => switch (dept) {
        'Acting' => 'Oyuncu',
        'Directing' => 'Yönetmen',
        'Writing' => 'Senarist',
        'Production' => 'Yapımcı',
        'Sound' => 'Ses',
        'Camera' => 'Kamera',
        _ => dept,
      };
}

class _ExpandableBio extends StatefulWidget {
  const _ExpandableBio({required this.bio});

  final String bio;

  @override
  State<_ExpandableBio> createState() => _ExpandableBioState();
}

class _ExpandableBioState extends State<_ExpandableBio> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.bio,
          maxLines: _expanded ? null : 5,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Daha az göster' : 'Devamını gör',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _CreditsSection extends StatelessWidget {
  const _CreditsSection({required this.credits, required this.name});

  final List<MediaItem> credits;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Filmografisi',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: credits.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 110,
              child: RepaintBoundary(
                child: MediaCard(item: credits[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
