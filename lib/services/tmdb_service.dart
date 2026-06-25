import 'dart:convert';
import 'package:http/http.dart' as http;

const String _tmdbApiKey = '2e928cd76f7f5ae46f6e022f5dcc2612';
const String _tmdbBase = 'https://api.themoviedb.org/3';
const String _imageBase = 'https://image.tmdb.org/t/p/w500';

class TmdbResult {
  final int id;
  final String title;
  final String year;
  final String poster;
  final String overview;
  final String type; // 'movie' or 'series'
  final List<String> genres;

  TmdbResult({
    required this.id,
    required this.title,
    required this.year,
    required this.poster,
    required this.overview,
    required this.type,
    this.genres = const [],
  });

  factory TmdbResult.fromJson(Map<String, dynamic> j, String type) {
    String rawDate = type == 'movie'
        ? (j['release_date'] ?? '')
        : (j['first_air_date'] ?? '');
    return TmdbResult(
      id: j['id'] ?? 0,
      title: type == 'movie'
          ? (j['title'] ?? j['name'] ?? 'Unknown')
          : (j['name'] ?? j['title'] ?? 'Unknown'),
      year: rawDate.length >= 4 ? rawDate.substring(0, 4) : '',
      poster: (j['poster_path'] != null && j['poster_path'] != '')
          ? '$_imageBase${j['poster_path']}'
          : '',
      overview: j['overview'] ?? '',
      type: type,
      genres: const [],
    );
  }
}

class TmdbService {
  /// Multi-search across movies and tv series.
  static Future<List<TmdbResult>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final url = Uri.parse(
      '$_tmdbBase/search/multi?api_key=$_tmdbApiKey&query=${Uri.encodeQueryComponent(query)}&language=en-US&page=1',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('TMDB search failed: ${res.statusCode}');
    }
    final data = json.decode(res.body);
    final results = (data['results'] as List?) ?? [];
    final list = <TmdbResult>[];
    for (final item in results) {
      final mediaType = item['media_type'] ?? '';
      if (mediaType == 'movie' || mediaType == 'tv') {
        list.add(TmdbResult.fromJson(
          item,
          mediaType == 'movie' ? 'movie' : 'series',
        ));
      }
    }
    return list;
  }

  /// Get details (with genres) for movie or series by tmdbId.
  static Future<List<String>> getGenres(int tmdbId, String type) async {
    final endpoint = type == 'movie' ? 'movie' : 'tv';
    final url = Uri.parse(
      '$_tmdbBase/$endpoint/$tmdbId?api_key=$_tmdbApiKey&language=en-US',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) return [];
    final data = json.decode(res.body);
    final genres = (data['genres'] as List?) ?? [];
    return genres.map<String>((g) => (g['name'] ?? '').toString()).toList();
  }
}
