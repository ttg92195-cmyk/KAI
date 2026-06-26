import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Centralized network image widget with consistent error/loading handling.
/// Uses cached_network_image for better caching and reliability.
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _placeholder();
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: const {
        'User-Agent': 'KAI-Post-Generator/1.0',
        'Accept': 'image/*,*/*',
      },
      placeholder: (context, _) => Container(
        width: width,
        height: height,
        color: Colors.black26,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFE50914),
            ),
          ),
        ),
      ),
      errorWidget: (context, _, __) => _placeholder(),
      errorListener: (e) {
        // Silent error - widget already shows fallback
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.black26,
      child: const Icon(Icons.broken_image, color: Colors.white24),
    );
  }
}
