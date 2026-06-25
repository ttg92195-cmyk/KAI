import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

class FormScreen extends StatefulWidget {
  final MoviePost post;
  final List<MoviePost> previousPosts;

  const FormScreen({
    super.key,
    required this.post,
    this.previousPosts = const [],
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  late MoviePost _post;
  late TextEditingController _titleCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _posterCtrl;
  late TextEditingController _overviewCtrl;
  late TextEditingController _resolutionCtrl;
  late TextEditingController _fileSizeCtrl;
  late TextEditingController _formatCtrl;
  late TextEditingController _categoriesCtrl;
  late TextEditingController _tmdbIdCtrl;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _titleCtrl = TextEditingController(text: _post.title);
    _yearCtrl = TextEditingController(text: _post.year);
    _posterCtrl = TextEditingController(text: _post.poster);
    _overviewCtrl = TextEditingController(text: _post.overview);
    _resolutionCtrl = TextEditingController(text: _post.resolution);
    _fileSizeCtrl = TextEditingController(text: _post.fileSize);
    _formatCtrl = TextEditingController(text: _post.format);
    _categoriesCtrl =
        TextEditingController(text: _post.categories.join(', '));
    _tmdbIdCtrl = TextEditingController(
        text: _post.tmdbId == null ? '' : _post.tmdbId.toString());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    _posterCtrl.dispose();
    _overviewCtrl.dispose();
    _resolutionCtrl.dispose();
    _fileSizeCtrl.dispose();
    _formatCtrl.dispose();
    _categoriesCtrl.dispose();
    _tmdbIdCtrl.dispose();
    super.dispose();
  }

  void _syncFromControllers() {
    _post.title = _titleCtrl.text.trim();
    _post.year = _yearCtrl.text.trim();
    _post.poster = _posterCtrl.text.trim();
    _post.overview = _overviewCtrl.text.trim();
    _post.resolution = _resolutionCtrl.text.trim();
    _post.fileSize = _fileSizeCtrl.text.trim();
    _post.format = _formatCtrl.text.trim();
    _post.categories = _categoriesCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final tid = int.tryParse(_tmdbIdCtrl.text.trim());
    _post.tmdbId = tid;
  }

  void _autoFillFromPrevious() {
    if (widget.previousPosts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous post available')),
      );
      return;
    }
    final prev = widget.previousPosts.last;
    setState(() {
      _resolutionCtrl.text = prev.resolution;
      _fileSizeCtrl.text = prev.fileSize;
      _formatCtrl.text = prev.format;
      _post.downloadLinks = prev.downloadLinks
          .map((l) => ServerLink(
                serverName: l.serverName,
                url: l.url,
                size: l.size,
                quality: l.quality,
                fileName: l.fileName,
              ))
          .toList();
      _post.watchLinks = prev.watchLinks
          .map((l) => ServerLink(
                serverName: l.serverName,
                url: l.url,
                size: l.size,
                quality: l.quality,
                fileName: l.fileName,
              ))
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filled from previous post')),
    );
  }

  void _save() {
    _syncFromControllers();
    if (_post.title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }
    Navigator.pop(context, _post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_post.type == 'series' ? 'Series Post' : 'Movie Post'),
        actions: [
          IconButton(
            tooltip: 'Auto-fill from previous',
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _autoFillFromPrevious,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // --- TMDB block ---
          _sectionLabel('TMDB Information'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _post.poster.isEmpty
                  ? Container(
                      width: 90,
                      height: 135,
                      color: Colors.black26,
                      child: const Icon(Icons.broken_image,
                          color: Colors.white24),
                    )
                  : Image.network(
                      _post.poster,
                      width: 90,
                      height: 135,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 135,
                        color: Colors.black26,
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _textField(_titleCtrl, 'Title'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _textField(_yearCtrl, 'Year')),
                        const SizedBox(width: 8),
                        Expanded(child: _textField(_tmdbIdCtrl, 'TMDB ID')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _post.type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const [
                        DropdownMenuItem(
                            value: 'movie', child: Text('Movie')),
                        DropdownMenuItem(
                            value: 'series', child: Text('Series')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _post.type = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _textField(_posterCtrl, 'Poster URL'),
          const SizedBox(height: 8),
          _textField(_overviewCtrl, 'Overview', maxLines: 4),
          const SizedBox(height: 8),
          _textField(_categoriesCtrl, 'Categories (comma separated)'),

          // --- File info ---
          const SizedBox(height: 20),
          _sectionLabel('File Information'),
          Row(
            children: [
              Expanded(child: _textField(_resolutionCtrl, 'Resolution')),
              const SizedBox(width: 8),
              Expanded(child: _textField(_fileSizeCtrl, 'File Size')),
              const SizedBox(width: 8),
              Expanded(child: _textField(_formatCtrl, 'Format')),
            ],
          ),

          // --- Download links ---
          const SizedBox(height: 20),
          _sectionHeader('Download Links', () {
            setState(() => _post.downloadLinks.add(ServerLink.empty()));
          }),
          ..._downloadLinkEditors(),

          // --- Watch links ---
          const SizedBox(height: 20),
          _sectionHeader('Watch Links', () {
            setState(() => _post.watchLinks.add(ServerLink.empty()));
          }),
          ..._watchLinkEditors(),

          // --- Seasons (only for series) ---
          if (_post.type == 'series') ...[
            const SizedBox(height: 20),
            _sectionHeader('Seasons', () {
              setState(() => _post.seasons.add(Season.empty()));
            }),
            ..._seasonEditors(),
          ],

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Save Post'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE50914),
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _sectionHeader(String text, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionLabel(text),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
      ],
    );
  }

  Widget _textField(TextEditingController c, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }

  List<Widget> _downloadLinkEditors() {
    final list = <Widget>[];
    for (var i = 0; i < _post.downloadLinks.length; i++) {
      final link = _post.downloadLinks[i];
      list.add(_LinkCard(
        index: i + 1,
        link: link,
        showFileName: true,
        onChanged: () => setState(() {}),
        onRemove: () => setState(() => _post.downloadLinks.removeAt(i)),
      ));
    }
    return list;
  }

  List<Widget> _watchLinkEditors() {
    final list = <Widget>[];
    for (var i = 0; i < _post.watchLinks.length; i++) {
      final link = _post.watchLinks[i];
      list.add(_LinkCard(
        index: i + 1,
        link: link,
        showFileName: false,
        onChanged: () => setState(() {}),
        onRemove: () => setState(() => _post.watchLinks.removeAt(i)),
      ));
    }
    return list;
  }

  List<Widget> _seasonEditors() {
    final list = <Widget>[];
    for (var i = 0; i < _post.seasons.length; i++) {
      final s = _post.seasons[i];
      list.add(_SeasonCard(
        season: s,
        index: i + 1,
        onChanged: () => setState(() {}),
        onRemove: () => setState(() => _post.seasons.removeAt(i)),
      ));
    }
    return list;
  }
}

// ---------- Link Card ----------
class _LinkCard extends StatelessWidget {
  final int index;
  final ServerLink link;
  final bool showFileName;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _LinkCard({
    required this.index,
    required this.link,
    required this.showFileName,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF15151C),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Link #$index',
                    style: const TextStyle(color: Colors.white70)),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: onRemove,
                ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Server Name'),
              controller: TextEditingController(text: link.serverName),
              onChanged: (v) {
                link.serverName = v;
                onChanged();
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'URL'),
              controller: TextEditingController(text: link.url),
              onChanged: (v) {
                link.url = v;
                onChanged();
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Size'),
                    controller: TextEditingController(text: link.size),
                    onChanged: (v) {
                      link.size = v;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Quality'),
                    controller: TextEditingController(text: link.quality),
                    onChanged: (v) {
                      link.quality = v;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
            if (showFileName)
              TextField(
                decoration: const InputDecoration(labelText: 'File Name'),
                controller: TextEditingController(text: link.fileName ?? ''),
                onChanged: (v) {
                  link.fileName = v;
                  onChanged();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ---------- Season Card ----------
class _SeasonCard extends StatelessWidget {
  final Season season;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _SeasonCard({
    required this.season,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A22),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Season #$index',
                    style: const TextStyle(color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: onRemove,
                ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Season Name'),
              controller: TextEditingController(text: season.name),
              onChanged: (v) {
                season.name = v;
                onChanged();
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Episodes',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                TextButton.icon(
                  onPressed: () {
                    season.episodes.add(Episode.empty());
                    onChanged();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Episode'),
                ),
              ],
            ),
            for (var i = 0; i < season.episodes.length; i++)
              _EpisodeCard(
                episode: season.episodes[i],
                index: i + 1,
                onChanged: onChanged,
                onRemove: () {
                  season.episodes.removeAt(i);
                  onChanged();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ---------- Episode Card ----------
class _EpisodeCard extends StatelessWidget {
  final Episode episode;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _EpisodeCard({
    required this.episode,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF15151C),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Episode #$index',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 18),
                  onPressed: onRemove,
                ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Episode Name'),
              controller: TextEditingController(text: episode.name),
              onChanged: (v) {
                episode.name = v;
                onChanged();
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Video URL'),
              controller: TextEditingController(text: episode.videoUrl),
              onChanged: (v) {
                episode.videoUrl = v;
                onChanged();
              },
            ),
            const SizedBox(height: 6),
            // Episode download links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Download Links',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                TextButton(
                  onPressed: () {
                    episode.downloadLinks.add(ServerLink.empty());
                    onChanged();
                  },
                  child: const Text('+ Link',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            for (var i = 0; i < episode.downloadLinks.length; i++)
              _MiniLinkEditor(
                link: episode.downloadLinks[i],
                index: i + 1,
                onChanged: onChanged,
                onRemove: () {
                  episode.downloadLinks.removeAt(i);
                  onChanged();
                },
              ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Watch Links',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                TextButton(
                  onPressed: () {
                    episode.watchLinks.add(ServerLink.empty());
                    onChanged();
                  },
                  child: const Text('+ Link',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            for (var i = 0; i < episode.watchLinks.length; i++)
              _MiniLinkEditor(
                link: episode.watchLinks[i],
                index: i + 1,
                onChanged: onChanged,
                onRemove: () {
                  episode.watchLinks.removeAt(i);
                  onChanged();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniLinkEditor extends StatelessWidget {
  final ServerLink link;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _MiniLinkEditor({
    required this.link,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      labelText: 'Server #$index', isDense: true),
                  controller: TextEditingController(text: link.serverName),
                  onChanged: (v) {
                    link.serverName = v;
                    onChanged();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    color: Colors.redAccent, size: 18),
                onPressed: onRemove,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          TextField(
            decoration:
                const InputDecoration(labelText: 'URL', isDense: true),
            controller: TextEditingController(text: link.url),
            onChanged: (v) {
              link.url = v;
              onChanged();
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: 'Size', isDense: true),
                  controller: TextEditingController(text: link.size),
                  onChanged: (v) {
                    link.size = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: 'Quality', isDense: true),
                  controller: TextEditingController(text: link.quality),
                  onChanged: (v) {
                    link.quality = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
