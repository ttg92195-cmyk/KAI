import 'package:flutter/material.dart';
import 'services/tmdb_service.dart';
import 'services/storage_service.dart';
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

enum PostFilter { all, movie, series }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MoviePost> _posts = [];
  final TextEditingController _searchCtrl = TextEditingController();

  // Filter & search state
  PostFilter _filter = PostFilter.all;
  String _searchQuery = '';

  // Multi-select state
  final Set<int> _selected = <int>{};
  bool _selectMode = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final loaded = await StorageService.loadPosts();
    if (!mounted) return;
    setState(() {
      _posts
        ..clear()
        ..addAll(loaded);
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await StorageService.savePosts(_posts);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MoviePost> get _filteredPosts {
    var list = _posts;
    if (_filter != PostFilter.all) {
      final typeStr = _filter == PostFilter.movie ? 'movie' : 'series';
      list = list.where((p) => p.type == typeStr).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.year.contains(q) ||
            p.categories.any((c) => c.toLowerCase().contains(q));
      }).toList();
    }
    return list;
  }

  void _openSearch() async {
    final result = await Navigator.push<TmdbResult>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    if (result == null) return;

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
      _persist();
    }
  }

  void _editPost(int index) async {
    final post = _posts[index];
    final edited = await Navigator.push<MoviePost>(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(
          post: post,
          previousPosts: _posts,
        ),
      ),
    );
    if (edited != null) {
      setState(() => _posts[index] = edited);
      _persist();
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

  void _toggleSelect(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
      if (_selected.isEmpty) _selectMode = false;
    });
  }

  void _enterSelectMode(int index) {
    setState(() {
      _selectMode = true;
      _selected.add(index);
    });
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selected.clear();
    });
  }

  void _selectAll() {
    final visible = _filteredPosts;
    final indexes = <int>{};
    for (var i = 0; i < _posts.length; i++) {
      if (visible.contains(_posts[i])) indexes.add(i);
    }
    setState(() {
      if (_selected.length == indexes.length) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(indexes);
      }
    });
  }

  void _deleteSelected() {
    if (_selected.isEmpty) return;
    final sorted = _selected.toList()..sort((a, b) => b.compareTo(a));
    setState(() {
      for (final i in sorted) {
        _posts.removeAt(i);
      }
      _selected.clear();
      _selectMode = false;
    });
    _persist();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleted selected posts')),
    );
  }

  void _deleteSingle(int index) {
    setState(() {
      _posts.removeAt(index);
      _selected.removeWhere((e) => e == index);
      // shift remaining selected indexes
      final newSel = <int>{};
      for (final e in _selected) {
        if (e > index) {
          newSel.add(e - 1);
        } else {
          newSel.add(e);
        }
      }
      _selected
        ..clear()
        ..addAll(newSel);
      if (_selected.isEmpty) _selectMode = false;
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredPosts;
    final allSelected =
        visible.isNotEmpty && _selected.length == visible.length;

    return Scaffold(
      appBar: AppBar(
        leading: _selectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectMode,
              )
            : null,
        title: _selectMode
            ? Text('${_selected.length} selected')
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
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
        actions: _selectMode
            ? [
                IconButton(
                  tooltip: allSelected ? 'Deselect all' : 'Select all',
                  icon: Icon(allSelected
                      ? Icons.deselect
                      : Icons.select_all),
                  onPressed: _selectAll,
                ),
                IconButton(
                  tooltip: 'Delete selected',
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  onPressed: _deleteSelected,
                ),
              ]
            : [
                IconButton(
                  onPressed: _openOutput,
                  icon: const Icon(Icons.code),
                  tooltip: 'View JSON',
                ),
              ],
      ),
      body: Column(
        children: [
          // Search + Filter bar
          if (!_selectMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) =>
                          setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search posts...',
                        isDense: true,
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.white54, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.white54, size: 20),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<PostFilter>(
                      value: _filter,
                      underline: const SizedBox(),
                      dropdownColor: const Color(0xFF1A1A22),
                      items: const [
                        DropdownMenuItem(
                          value: PostFilter.all,
                          child: Text('All',
                              style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: PostFilter.movie,
                          child: Text('Movies',
                              style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: PostFilter.series,
                          child: Text('Series',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _filter = v);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Post count
          if (!_selectMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Row(
                children: [
                  Text(
                    _posts.isEmpty
                        ? 'No posts'
                        : (_searchQuery.isNotEmpty || _filter != PostFilter.all
                            ? '${visible.length} of ${_posts.length} posts'
                            : '${_posts.length} post${_posts.length == 1 ? "" : "s"}'),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Posts list
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE50914),
                    ),
                  )
                : _posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_filter_outlined,
                            size: 80, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        const Text(
                          'No posts yet',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap + to search TMDB and create a post',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : visible.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 60, color: Colors.grey[700]),
                            const SizedBox(height: 8),
                            const Text(
                              'No posts match your search',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            12, 4, 12, 80),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, visIdx) {
                          final post = visible[visIdx];
                          final realIndex = _posts.indexOf(post);
                          final selected =
                              _selected.contains(realIndex);

                          return GestureDetector(
                            onLongPress: () =>
                                _enterSelectMode(realIndex),
                            child: Card(
                              color: selected
                                  ? const Color(0xFF2A1015)
                                  : const Color(0xFF15151C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: selected
                                    ? const BorderSide(
                                        color: Color(0xFFE50914),
                                        width: 1.5)
                                    : BorderSide.none,
                              ),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.all(8),
                                leading: _selectMode
                                    ? Checkbox(
                                        value: selected,
                                        onChanged: (_) =>
                                            _toggleSelect(realIndex),
                                        activeColor:
                                            const Color(0xFFE50914),
                                      )
                                    : (post.poster.isEmpty
                                        ? Container(
                                            width: 50,
                                            color: Colors.black26,
                                            child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.white30),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Image.network(
                                              post.poster,
                                              width: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                width: 50,
                                                color: Colors.black26,
                                                child: const Icon(
                                                    Icons.broken_image,
                                                    color:
                                                        Colors.white30),
                                              ),
                                            ),
                                          )),
                                title: Text(
                                  post.title.isEmpty
                                      ? '(untitled)'
                                      : post.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  '${post.type.toUpperCase()}  •  ${post.year}  •  ${post.categories.join(", ")}',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12),
                                ),
                                trailing: _selectMode
                                    ? IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent),
                                        onPressed: () =>
                                            _deleteSingle(realIndex),
                                      )
                                    : Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Colors
                                                    .white70),
                                            tooltip: 'Edit',
                                            onPressed: () =>
                                                _editPost(realIndex),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors
                                                    .redAccent),
                                            tooltip: 'Delete',
                                            onPressed: () =>
                                                _deleteSingle(
                                                    realIndex),
                                          ),
                                        ],
                                      ),
                                onTap: _selectMode
                                    ? () =>
                                        _toggleSelect(realIndex)
                                    : () => _editPost(realIndex),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _openSearch,
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Post'),
            ),
    );
  }
}
