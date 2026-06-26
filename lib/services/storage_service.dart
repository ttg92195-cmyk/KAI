import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Local persistence for posts using SharedPreferences.
/// Posts are stored as a single JSON string under key `kai_posts`.
class StorageService {
  static const String _key = 'kai_posts';

  static Future<List<MoviePost>> loadPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return [];
      final movies = decoded['movies'];
      if (movies is! List) return [];
      return movies
          .map<MoviePost?>((m) {
            try {
              return MoviePost.fromJson(m as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<MoviePost>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> savePosts(List<MoviePost> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode({
        'movies': posts.map((p) => p.toJson()).toList(),
      });
      await prefs.setString(_key, encoded);
    } catch (e) {
      // silent fail - persistence is best-effort
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
