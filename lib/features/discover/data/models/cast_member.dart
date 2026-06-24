import '../../../../core/constants/api_constants.dart';

/// A single cast member from a title's credits.
class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  final int id;
  final String name;
  final String character;
  final String? profilePath;

  String? profileUrl({String size = ApiConstants.profileSize}) =>
      ApiConstants.imageUrl(profilePath, size: size);

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
        id: json['id'] as int,
        name: (json['name'] ?? '') as String,
        character: (json['character'] ?? '') as String,
        profilePath: json['profile_path'] as String?,
      );
}
