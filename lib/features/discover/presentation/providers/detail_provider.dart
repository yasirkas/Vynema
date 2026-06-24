import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/models/media_detail.dart';
import '../../data/models/media_item.dart';

/// Identifies a title to fetch detail for (used as a family argument).
class DetailRef {
  const DetailRef(this.type, this.id);
  final MediaType type;
  final int id;

  @override
  bool operator ==(Object other) =>
      other is DetailRef && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);
}

/// Fetches full detail (with credits) for a given title.
final detailProvider =
    FutureProvider.autoDispose.family<MediaDetail, DetailRef>(
  (ref, arg) =>
      ref.watch(mediaRepositoryProvider).getDetail(arg.type, arg.id),
);
