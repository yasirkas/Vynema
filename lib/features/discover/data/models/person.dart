import '../../../../core/constants/api_constants.dart';
import 'media_item.dart';

class Person {
  const Person({
    required this.id,
    required this.name,
    required this.biography,
    required this.birthday,
    required this.placeOfBirth,
    required this.profilePath,
    required this.knownForDepartment,
    required this.credits,
  });

  final int id;
  final String name;
  final String biography;
  final String? birthday;
  final String? placeOfBirth;
  final String? profilePath;
  final String knownForDepartment;
  final List<MediaItem> credits;

  String? profileUrl({String size = ApiConstants.profileSize}) =>
      ApiConstants.imageUrl(profilePath, size: size);

  String? get birthYear {
    if (birthday == null || birthday!.length < 4) return null;
    return birthday!.substring(0, 4);
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    final castJson = (json['combined_credits']?['cast'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((j) => j['poster_path'] != null)
        .toList()
      ..sort((a, b) {
        final pa = (a['popularity'] as num?) ?? 0;
        final pb = (b['popularity'] as num?) ?? 0;
        return pb.compareTo(pa);
      });

    // Deduplicate by id+mediaType (TV shows appear once per season/episode).
    // MediaItem.== uses id+mediaType so LinkedHashSet preserves popularity order.
    final credits = castJson
        .map((j) => MediaItem.fromJson(j))
        .toSet()
        .take(30)
        .toList();

    return Person(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      biography: (json['biography'] ?? '') as String,
      birthday: json['birthday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      profilePath: json['profile_path'] as String?,
      knownForDepartment: (json['known_for_department'] ?? '') as String,
      credits: credits,
    );
  }
}
