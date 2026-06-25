import 'package:flutter/material.dart';
import 'services/tmdb_service.dart';
import 'screens/search_screen.dart';
import 'screens/form_screen.dart';
import 'screens/output_screen.dart';
import 'models/models.dart';

void main() {
  runApp(const KaiApp());
}

class KaiApp extends StatelessWidget {
  const KaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAI Post Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE50914),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0B0F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111114),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE50914),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MoviePost> _posts = [];

  void _openSearch() async {
    final result = await Navigator.push<TmdbResult>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    if (result == null) return;

    // Fetch genres
    List<String> genres = [];
    try {
      genres = await TmdbService.getGenres(result.id, result.type);
    } catch (_) {}

    final post = MoviePost(
      title: result.title,
      year: result.year,
      poster: result.poster,
      overview: result.overview,
      type: result.type,
      tmdbId: result.id,
      categories: genres,
    );

    if (!mounted) return;
    final created = await Navigator.push<MoviePost>(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(
          post: post,
          previousPosts: _posts,
        ),
      ),
    );
    if (created != null) {
      setState(() => _posts.add(created));
    }
  }

  void _openOutput() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OutputScreen(posts: _posts),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE50914),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'KAI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Post Generator'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openOutput,
            icon: const Icon(Icons.code),
            tooltip: 'View JSON',
          ),
        ],
      ),
      body: _posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_filter_outlined,
                      size: 80, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  const Text(
                    'No posts yet',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to search TMDB and create a post',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = _posts[i];
                return Card(
                  color: const Color(0xFF15151C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: p.poster.isEmpty
                        ? Container(
                            width: 50,
                            color: Colors.black26,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white30),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              p.poster,
                              width: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                color: Colors.black26,
                                child: const Icon(Icons.broken_image,
                                    color: Colors.white30),
                              ),
                            ),
                          ),
                    title: Text(
                      p.title.isEmpty ? '(untitled)' : p.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${p.type.toUpperCase()}  •  ${p.year}  •  ${p.categories.join(", ")}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      onPressed: () =>
                          setState(() => _posts.removeAt(i)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSearch,
        backgroundColor: const Color(0xFFE50914),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }
}
