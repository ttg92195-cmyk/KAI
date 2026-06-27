import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../widgets/app_network_image.dart';

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

    // Live-update poster preview as user types the URL
    _posterCtrl.addListener(() {
      final v = _posterCtrl.text.trim();
      if (v != _post.poster) {
        setState(() => _post.poster = v);
      }
    });
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
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
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
                  : AppNetworkImage(
                      url: _post.poster,
                      width: 90,
                      height: 135,
                    ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    _textField(_titleCtrl, 'Title'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _textField(_yearCtrl, 'Year')),
                        const SizedBox(width: 10),
                        Expanded(child: _textField(_tmdbIdCtrl, 'TMDB ID')),
                      ],
                    ),
                    const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          _textField(_posterCtrl, 'Poster URL'),
          const SizedBox(height: 10),
          _textField(_overviewCtrl, 'Overview', maxLines: 4),
          const SizedBox(height: 10),
          _textField(_categoriesCtrl, 'Categories (comma separated)'),

          // --- File info ---
          _sectionHeight(),
          _sectionLabel('File Information'),
          Row(
            children: [
              Expanded(child: _textField(_resolutionCtrl, 'Resolution')),
              const SizedBox(width: 10),
              Expanded(child: _textField(_fileSizeCtrl, 'File Size')),
              const SizedBox(width: 10),
              Expanded(child: _textField(_formatCtrl, 'Format')),
            ],
          ),

          // --- Download links ---
          _sectionHeight(),
          _linksHeader('Download Links', () {
            setState(() => _post.downloadLinks.add(ServerLink.empty()));
          }, () {
            setState(() => _addAutoSixLinks(_post.downloadLinks));
          }),
          for (var i = 0; i < _post.downloadLinks.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LinkCard(
                key: ValueKey('dl_$i\_${_post.downloadLinks[i].hashCode}'),
                index: i + 1,
                link: _post.downloadLinks[i],
                showFileName: true,
                onRemove: () =>
                    setState(() => _post.downloadLinks.removeAt(i)),
              ),
            ),

          // --- Watch links ---
          _sectionHeight(),
          _linksHeader('Watch Links', () {
            setState(() => _post.watchLinks.add(ServerLink.empty()));
          }, () {
            setState(() => _addAutoSixLinks(_post.watchLinks));
          }),
          for (var i = 0; i < _post.watchLinks.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LinkCard(
                key: ValueKey('wl_$i\_${_post.watchLinks[i].hashCode}'),
                index: i + 1,
                link: _post.watchLinks[i],
                showFileName: false,
                onRemove: () =>
                    setState(() => _post.watchLinks.removeAt(i)),
              ),
            ),

          // --- Seasons (only for series) ---
          if (_post.type == 'series') ...[
            const SizedBox(height: 20),
            _sectionHeader('Seasons', () {
              setState(() => _post.seasons.add(Season.empty()));
            }),
            for (var i = 0; i < _post.seasons.length; i++)
              SeasonCard(
                key: ValueKey('season_$i\_${_post.seasons[i].hashCode}'),
                season: _post.seasons[i],
                index: i + 1,
                onRemove: () => setState(() => _post.seasons.removeAt(i)),
              ),
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

  Widget _sectionHeight() => const SizedBox(height: 24);

  /// Section header with two actions: +1 (Add) and Auto +6 (creates 6 links with
  /// pre-filled server names: Server 1, Server 1, Server 2, Server 2, Server 3, Server 3).
  Widget _linksHeader(String text, VoidCallback onAddOne, VoidCallback onAutoSix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE50914),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: onAutoSix,
                icon: const Icon(Icons.bolt, size: 16, color: Color(0xFFE50914)),
                label: const Text('Auto +6',
                    style: TextStyle(color: Color(0xFFE50914))),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              TextButton.icon(
                onPressed: onAddOne,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Adds 6 ServerLinks with pre-filled server names:
  ///   Link #1, #2 -> "Server 1"
  ///   Link #3, #4 -> "Server 2"
  ///   Link #5, #6 -> "Server 3"
  void _addAutoSixLinks(List<ServerLink> list) {
    final serverNames = [
      'Server 1', 'Server 1',
      'Server 2', 'Server 2',
      'Server 3', 'Server 3',
    ];
    for (final name in serverNames) {
      list.add(ServerLink(serverName: name, url: ''));
    }
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
      decoration: InputDecoration(
        labelText: label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ---------- Link Card (StatefulWidget - persistent controllers) ----------
class LinkCard extends StatefulWidget {
  final int index;
  final ServerLink link;
  final bool showFileName;
  final VoidCallback onRemove;

  const LinkCard({
    super.key,
    required this.index,
    required this.link,
    required this.showFileName,
    required this.onRemove,
  });

  @override
  State<LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends State<LinkCard> {
  late TextEditingController _serverCtrl;
  late TextEditingController _urlCtrl;
  late TextEditingController _sizeCtrl;
  late TextEditingController _qualityCtrl;
  late TextEditingController _fileNameCtrl;

  @override
  void initState() {
    super.initState();
    _serverCtrl = TextEditingController(text: widget.link.serverName);
    _urlCtrl = TextEditingController(text: widget.link.url);
    _sizeCtrl = TextEditingController(text: widget.link.size);
    _qualityCtrl = TextEditingController(text: widget.link.quality);
    _fileNameCtrl = TextEditingController(text: widget.link.fileName ?? '');

    _serverCtrl.addListener(() => widget.link.serverName = _serverCtrl.text);
    _urlCtrl.addListener(() => widget.link.url = _urlCtrl.text);
    _sizeCtrl.addListener(() => widget.link.size = _sizeCtrl.text);
    _qualityCtrl.addListener(() => widget.link.quality = _qualityCtrl.text);
    _fileNameCtrl.addListener(() => widget.link.fileName = _fileNameCtrl.text);
  }

  @override
  void dispose() {
    _serverCtrl.dispose();
    _urlCtrl.dispose();
    _sizeCtrl.dispose();
    _qualityCtrl.dispose();
    _fileNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF15151C),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Link #${widget.index}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              decoration: const InputDecoration(labelText: 'Server Name'),
              controller: _serverCtrl,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'URL'),
              controller: _urlCtrl,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Size'),
                    controller: _sizeCtrl,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Quality'),
                    controller: _qualityCtrl,
                  ),
                ),
              ],
            ),
            if (widget.showFileName) ...[
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'File Name'),
                controller: _fileNameCtrl,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------- Season Card (StatefulWidget) ----------
class SeasonCard extends StatefulWidget {
  final Season season;
  final int index;
  final VoidCallback onRemove;

  const SeasonCard({
    super.key,
    required this.season,
    required this.index,
    required this.onRemove,
  });

  @override
  State<SeasonCard> createState() => _SeasonCardState();
}

class _SeasonCardState extends State<SeasonCard> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.season.name);
    _nameCtrl.addListener(() {
      widget.season.name = _nameCtrl.text;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A22),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Season #${widget.index}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              decoration: const InputDecoration(labelText: 'Season Name'),
              controller: _nameCtrl,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Episodes',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      widget.season.episodes.add(Episode.empty());
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Episode'),
                ),
              ],
            ),
            for (var i = 0; i < widget.season.episodes.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: EpisodeCard(
                  key: ValueKey(
                      'ep_${widget.index}_$i\_${widget.season.episodes[i].hashCode}'),
                  episode: widget.season.episodes[i],
                  index: i + 1,
                  onRemove: () {
                    setState(() {
                      widget.season.episodes.removeAt(i);
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------- Episode Card (StatefulWidget) ----------
class EpisodeCard extends StatefulWidget {
  final Episode episode;
  final int index;
  final VoidCallback onRemove;

  const EpisodeCard({
    super.key,
    required this.episode,
    required this.index,
    required this.onRemove,
  });

  @override
  State<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends State<EpisodeCard> {
  late TextEditingController _nameCtrl;
  late TextEditingController _urlCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.episode.name);
    _urlCtrl = TextEditingController(text: widget.episode.videoUrl);
    _nameCtrl.addListener(() => widget.episode.name = _nameCtrl.text);
    _urlCtrl.addListener(() => widget.episode.videoUrl = _urlCtrl.text);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF15151C),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Episode #${widget.index}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 18),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextField(
              decoration: const InputDecoration(labelText: 'Episode Name'),
              controller: _nameCtrl,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'Video URL'),
              controller: _urlCtrl,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Download Links',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      widget.episode.downloadLinks.add(ServerLink.empty());
                    });
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            for (var i = 0; i < widget.episode.downloadLinks.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: MiniLinkEditor(
                  key: ValueKey(
                      'epdl_${widget.index}_$i\_${widget.episode.downloadLinks[i].hashCode}'),
                  link: widget.episode.downloadLinks[i],
                  index: i + 1,
                  onRemove: () {
                    setState(() {
                      widget.episode.downloadLinks.removeAt(i);
                    });
                  },
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Watch Links',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      widget.episode.watchLinks.add(ServerLink.empty());
                    });
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            for (var i = 0; i < widget.episode.watchLinks.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: MiniLinkEditor(
                  key: ValueKey(
                      'epwl_${widget.index}_$i\_${widget.episode.watchLinks[i].hashCode}'),
                  link: widget.episode.watchLinks[i],
                  index: i + 1,
                  onRemove: () {
                    setState(() {
                      widget.episode.watchLinks.removeAt(i);
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------- Mini Link Editor (StatefulWidget) ----------
class MiniLinkEditor extends StatefulWidget {
  final ServerLink link;
  final int index;
  final VoidCallback onRemove;

  const MiniLinkEditor({
    super.key,
    required this.link,
    required this.index,
    required this.onRemove,
  });

  @override
  State<MiniLinkEditor> createState() => _MiniLinkEditorState();
}

class _MiniLinkEditorState extends State<MiniLinkEditor> {
  late TextEditingController _serverCtrl;
  late TextEditingController _urlCtrl;
  late TextEditingController _sizeCtrl;
  late TextEditingController _qualityCtrl;

  @override
  void initState() {
    super.initState();
    _serverCtrl = TextEditingController(text: widget.link.serverName);
    _urlCtrl = TextEditingController(text: widget.link.url);
    _sizeCtrl = TextEditingController(text: widget.link.size);
    _qualityCtrl = TextEditingController(text: widget.link.quality);

    _serverCtrl.addListener(() => widget.link.serverName = _serverCtrl.text);
    _urlCtrl.addListener(() => widget.link.url = _urlCtrl.text);
    _sizeCtrl.addListener(() => widget.link.size = _sizeCtrl.text);
    _qualityCtrl.addListener(() => widget.link.quality = _qualityCtrl.text);
  }

  @override
  void dispose() {
    _serverCtrl.dispose();
    _urlCtrl.dispose();
    _sizeCtrl.dispose();
    _qualityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      labelText: 'Server #${widget.index}', isDense: true),
                  controller: _serverCtrl,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    color: Colors.redAccent, size: 18),
                onPressed: widget.onRemove,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            decoration:
                const InputDecoration(labelText: 'URL', isDense: true),
            controller: _urlCtrl,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: 'Size', isDense: true),
                  controller: _sizeCtrl,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: 'Quality', isDense: true),
                  controller: _qualityCtrl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
