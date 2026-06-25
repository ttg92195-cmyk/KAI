import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<TmdbResult> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _doSearch(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await TmdbService.search(q);
      setState(() {
        _results = r;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search TMDB')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _doSearch,
              decoration: InputDecoration(
                hintText: 'Search movies & series...',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _controller.clear();
                          _doSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_error!,
                  style: const TextStyle(color: Colors.redAccent)),
            ),
          Expanded(
            child: _results.isEmpty && !_loading
                ? Center(
                    child: Icon(Icons.movie_outlined,
                        size: 80, color: Colors.grey[800]),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _results.length,
                    itemBuilder: (context, i) {
                      final r = _results[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        leading: r.poster.isEmpty
                            ? Container(
                                width: 50,
                                height: 75,
                                color: Colors.black26,
                                child: const Icon(Icons.movie,
                                    color: Colors.white24),
                              )
                            : Image.network(
                                r.poster,
                                width: 50,
                                height: 75,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 75,
                                  color: Colors.black26,
                                ),
                              ),
                        title: Text(r.title,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          '${r.type.toUpperCase()}  •  ${r.year.isEmpty ? "—" : r.year}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                        onTap: () => Navigator.pop(context, r),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
