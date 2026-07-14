import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// Visionneuse plein écran de la galerie showroom : swipe gauche/droite,
/// pinch-to-zoom, double-tap zoom, pan pendant le zoom sans interférer avec
/// le changement de page. Utilise `photo_view` (aucune dépendance existante
/// équivalente dans le projet).
class ShowroomGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ShowroomGalleryViewer({super.key, required this.images, required this.initialIndex});

  @override
  State<ShowroomGalleryViewer> createState() => _ShowroomGalleryViewerState();
}

class _ShowroomGalleryViewerState extends State<ShowroomGalleryViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            builder: (context, i) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[i]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: widget.images[i]),
              );
            },
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
