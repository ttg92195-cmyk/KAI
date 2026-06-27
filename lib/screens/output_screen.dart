import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class OutputScreen extends StatefulWidget {
  final List<MoviePost> posts;

  const OutputScreen({super.key, required this.posts});

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  late String _jsonStr;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _jsonStr = StorageService.buildJsonString(widget.posts);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _jsonStr));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON copied to clipboard')),
      );
    }
  }

  Future<void> _saveToFile() async {
    setState(() => _busy = true);
    final path = await StorageService.exportToFile(widget.posts);
    setState(() => _busy = false);
    if (!mounted) return;
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to: $path')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save file')),
      );
    }
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    final ok = await StorageService.shareFile(widget.posts);
    setState(() => _busy = false);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Output'),
        actions: [
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy),
            onPressed: _busy ? null : _copy,
          ),
          IconButton(
            tooltip: 'Save to file',
            icon: const Icon(Icons.save_alt),
            onPressed: _busy ? null : _saveToFile,
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: _busy ? null : _share,
          ),
        ],
      ),
      body: widget.posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.code_off, size: 60, color: Colors.white24),
                  SizedBox(height: 12),
                  Text('No posts yet',
                      style: TextStyle(color: Colors.white38)),
                ],
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F14),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: SelectableText(
                      _jsonStr,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.greenAccent,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                if (_busy)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE50914),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
