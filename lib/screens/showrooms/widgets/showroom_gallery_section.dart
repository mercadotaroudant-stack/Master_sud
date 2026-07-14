import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import 'showroom_gallery_viewer.dart';

/// Section "Galerie" : preview principal en PageView + indicateurs, ouvre la
/// visionneuse plein écran au tap. Masquée entièrement si Firebase n'a
/// aucune image de galerie pour ce showroom.
class ShowroomGallerySection extends StatefulWidget {
  final List<String> images;

  const ShowroomGallerySection({super.key, required this.images});

  @override
  State<ShowroomGallerySection> createState() => _ShowroomGallerySectionState();
}

class _ShowroomGallerySectionState extends State<ShowroomGallerySection> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShowroomGalleryViewer(images: widget.images, initialIndex: index),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Galerie', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.srNameText)),
        const SizedBox(height: 17),
        ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            children: [
              SizedBox(
                height: 225,
                width: double.infinity,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () => _openViewer(i),
                      child: CachedNetworkImage(
                        imageUrl: images[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(color: AppColors.srNavy),
                        errorWidget: (_, __, ___) => Container(color: AppColors.srNavy),
                      ),
                    );
                  },
                ),
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 30 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? AppColors.srGold : const Color(0xFFAEB4C0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
