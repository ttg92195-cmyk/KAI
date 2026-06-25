import 'package:flutter_test/flutter_test.dart';
import 'package:kai_post_generator/models/models.dart';

void main() {
  test('MoviePost toJson produces expected structure', () {
    final post = MoviePost(
      title: 'Test',
      year: '2026',
      poster: 'https://example.com/x.jpg',
      overview: 'desc',
      type: 'movie',
      tmdbId: 123,
      categories: ['Action'],
      resolution: '1080p',
      fileSize: '2 GB',
      format: 'MP4',
      downloadLinks: [
        ServerLink(
          serverName: 'S1',
          url: 'https://e.com/d.mp4',
          size: '2 GB',
          quality: '1080p',
          fileName: 'Test.mp4',
        ),
      ],
      watchLinks: [
        ServerLink(
          serverName: 'P1',
          url: 'https://e.com/embed',
          quality: '1080p',
        ),
      ],
    );
    final json = post.toJson();
    expect(json['title'], 'Test');
    expect(json['tmdbId'], 123);
    expect(json['type'], 'movie');
    expect((json['downloadLinks'] as List).length, 1);
    expect((json['seasons'] as List).length, 0);
  });

  test('Series post with seasons serializes correctly', () {
    final post = MoviePost(
      title: 'Series X',
      year: '2025',
      poster: '',
      overview: '',
      type: 'series',
      tmdbId: 9,
      seasons: [
        Season(
          name: 'Season 1',
          episodes: [
            Episode(
              name: 'Episode 1',
              videoUrl: 'https://e.com/embed/s1e1',
              downloadLinks: [
                ServerLink(
                    serverName: 'S1',
                    url: 'https://e.com/d.mp4',
                    size: '800 MB',
                    quality: '1080p'),
              ],
            ),
          ],
        ),
      ],
    );
    final json = post.toJson();
    expect(json['type'], 'series');
    expect((json['seasons'] as List).length, 1);
    final s = (json['seasons'] as List).first;
    expect((s['episodes'] as List).length, 1);
  });
}
