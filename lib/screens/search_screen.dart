import 'dart:async';
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
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<TmdbResult> _results = [];
  bool _loading = false;
  String? _error;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    setState(() {});
    if (q == _lastQuery) return;
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = null;
        _loading = false;
        _lastQuery = '';
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _doSearch(q);
    });
  }

  Future<void> _doSearch(String q) async {
    if (q.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _lastQuery = q;
    });
    try {
      final r = await TmdbService.search(q);
      if (!mounted) return;
      setState(() {
        _results = r;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _doSearch,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Type to search movies & series...',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _controller.clear();
                          _onChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(
                color: Color(0xFFE50914),
                backgroundColor: Color(0xFF1A1A22),
              ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_outlined,
                            size: 80, color: Colors.grey[800]),
                        const SizedBox(height: 8),
                        const Text(
                          'Start typing to search',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
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
