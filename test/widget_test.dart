import 'package:flutter_test/flutter_test.dart';
import 'package:vynema/features/discover/data/models/media_item.dart';

void main() {
  group('MediaItem.fromJson', () {
    test('parses a movie payload and builds image URLs', () {
      final item = MediaItem.fromJson(const {
        'id': 1,
        'media_type': 'movie',
        'title': 'Inception',
        'overview': 'A thief...',
        'poster_path': '/poster.jpg',
        'vote_average': 8.4,
        'release_date': '2010-07-16',
      });

      expect(item.id, 1);
      expect(item.mediaType, MediaType.movie);
      expect(item.title, 'Inception');
      expect(item.year, '2010');
      expect(item.posterUrl(), contains('/poster.jpg'));
    });

    test('uses TV fields and fallback type when media_type is absent', () {
      final item = MediaItem.fromJson(const {
        'id': 2,
        'name': 'Breaking Bad',
        'overview': '',
        'first_air_date': '2008-01-20',
        'vote_average': 9,
      }, fallbackType: MediaType.tv);

      expect(item.mediaType, MediaType.tv);
      expect(item.title, 'Breaking Bad');
      expect(item.year, '2008');
      expect(item.posterUrl(), isNull);
    });

    test('round-trips through toJson/fromJson', () {
      const original = MediaItem(
        id: 3,
        mediaType: MediaType.tv,
        title: 'Dark',
        overview: 'Time travel.',
        posterPath: '/dark.jpg',
        backdropPath: null,
        voteAverage: 8.7,
        releaseDate: '2017-12-01',
      );

      final restored = MediaItem.fromJson(original.toJson());
      expect(restored, original);
      expect(restored.title, 'Dark');
    });
  });
}
