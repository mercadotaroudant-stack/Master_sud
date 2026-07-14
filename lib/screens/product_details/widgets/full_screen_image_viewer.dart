import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Visionneuse plein écran avec zoom (pinch-to-zoom) pour les images
/// d'exemples d'application. Ouverte au tap sur une image de la liste.
class FullScreenImageViewer extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({super.key, required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, i) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 48),
              ),
            ),
          );
        },
      ),
    );
  }
}
