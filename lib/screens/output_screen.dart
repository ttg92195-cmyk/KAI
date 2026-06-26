import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

class OutputScreen extends StatelessWidget {
  final List<MoviePost> posts;

  const OutputScreen({super.key, required this.posts});

  String _buildJson() {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert({
      'movies': posts.map((p) => p.toJson()).toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final jsonStr = _buildJson();
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Output'),
        actions: [
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: jsonStr));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('JSON copied to clipboard')),
                );
              }
            },
          ),
        ],
      ),
      body: posts.isEmpty
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: SelectableText(
                  jsonStr,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.greenAccent,
                    height: 1.4,
                  ),
                ),
              ),
            ),
    );
  }
}
