import '../../../../core/constants/api_constants.dart';

class WatchProvider {
  const WatchProvider({
    required this.id,
    required this.name,
    required this.logoPath,
  });

  final int id;
  final String name;
  final String? logoPath;

  String? logoUrl() => ApiConstants.imageUrl(logoPath, size: 'w92');

  factory WatchProvider.fromJson(Map<String, dynamic> json) => WatchProvider(
        id: json['provider_id'] as int,
        name: (json['provider_name'] ?? '') as String,
        logoPath: json['logo_path'] as String?,
      );
}
