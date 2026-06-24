import 'package:flutter/material.dart';

import '../../../../core/l10n.dart';
import '../../data/models/discover_filter.dart';
import '../../data/models/media_item.dart';
import '../discover_l10n.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key, required this.initial});

  final DiscoverFilter initial;

  static Future<DiscoverFilter?> show(
    BuildContext context, {
    required DiscoverFilter initial,
  }) =>
      showModalBottomSheet<DiscoverFilter>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => FilterBottomSheet(initial: initial),
      );

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late MediaType _mediaType;
  late SortBy _sortBy;
  late double _minRating;
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mediaType = widget.initial.mediaType;
    _sortBy = widget.initial.sortBy;
    _minRating = widget.initial.minRating;
    if (widget.initial.year != null) {
      _yearController.text = widget.initial.year.toString();
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.filterTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label(context, l10n.filterContentType),
          const SizedBox(height: 8),
          SegmentedButton<MediaType>(
            segments: [
              ButtonSegment(
                  value: MediaType.movie, label: Text(l10n.typeMovie)),
              ButtonSegment(value: MediaType.tv, label: Text(l10n.typeTv)),
            ],
            selected: {_mediaType},
            onSelectionChanged: (s) => setState(() => _mediaType = s.first),
          ),
          const SizedBox(height: 20),
          _label(context, l10n.filterSortBy),
          const SizedBox(height: 8),
          RadioGroup<SortBy>(
            groupValue: _sortBy,
            onChanged: (v) => setState(() => _sortBy = v!),
            child: Column(
              children: SortBy.values.map(
                (s) => RadioListTile<SortBy>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(sortByLabel(l10n, s)),
                  value: s,
                ),
              ).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _label(context, l10n.filterMinRating),
              const Spacer(),
              Text(
                _minRating == 0
                    ? l10n.filterRatingAll
                    : _minRating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          Slider(
            value: _minRating,
            min: 0,
            max: 9,
            divisions: 18,
            onChanged: (v) => setState(() => _minRating = v),
          ),
          const SizedBox(height: 8),
          _label(context, l10n.filterYear),
          const SizedBox(height: 8),
          TextField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: l10n.filterYearHint,
              prefixIcon: const Icon(Icons.calendar_today_outlined),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: _apply,
            child: Text(l10n.filterApply),
          ),
        ],
      ),
    );
  }

  void _apply() {
    final yearText = _yearController.text.trim();
    final year = yearText.isEmpty ? null : int.tryParse(yearText);
    Navigator.pop(
      context,
      DiscoverFilter(
        mediaType: _mediaType,
        sortBy: _sortBy,
        minRating: _minRating,
        year: year,
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      );
}
