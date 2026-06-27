import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

  /// Build the JSON string for the given posts.
  static String buildJsonString(List<MoviePost> posts) {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert({
      'movies': posts.map((p) => p.toJson()).toList(),
    });
  }

  /// Export posts as a .json file in the app's documents directory,
  /// then return the file path.
  static Future<String?> exportToFile(List<MoviePost> posts,
      {String? fileName}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final name = (fileName?.isNotEmpty == true)
          ? fileName!
          : 'kai_posts_${DateTime.now().millisecondsSinceEpoch}';
      final safeName = name.endsWith('.json') ? name : '$name.json';
      final file = File('${dir.path}/$safeName');
      await file.writeAsString(buildJsonString(posts));
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Share the JSON file via the OS share sheet.
  static Future<bool> shareFile(List<MoviePost> posts,
      {String? fileName}) async {
    try {
      final path = await exportToFile(posts, fileName: fileName);
      if (path == null) return false;
      await Share.shareXFiles([XFile(path)],
          text: 'KAI Posts JSON',
          subject: fileName ?? 'kai_posts.json');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Pick a JSON file from device and parse it into posts.
  /// Returns null if user cancels or file is invalid.
  static Future<List<MoviePost>?> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;
      final file = result.files.first;
      String content;
      if (file.bytes != null) {
        content = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        return null;
      }
      final decoded = jsonDecode(content);
      if (decoded is! Map) return null;
      final movies = decoded['movies'];
      if (movies is! List) return null;
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
      return null;
    }
  }
}

