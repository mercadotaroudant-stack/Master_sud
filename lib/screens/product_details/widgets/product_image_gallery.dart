import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// Slider d'images produit (PageView) avec indicateurs de pagination et
/// badge PROMO conditionnel. Les images viennent de [ProductModel.galleryImages]
/// (Firebase) — aucune image de démonstration n'est utilisée.
class ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final bool showPromoBadge;

  const ProductImageGallery({super.key, required this.images, required this.showPromoBadge});

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Stack(
      children: [
        SizedBox(
          height: 320,
          width: double.infinity,
          child: images.isEmpty
              ? const _ImageFallback()
              : PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: CachedNetworkImage(
                        imageUrl: images[i],
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (_, __, ___) => const _ImageFallback(),
                      ),
                    );
                  },
                ),
        ),
        if (widget.showPromoBadge)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.pdPromoRed,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'PROMO',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.4),
              ),
            ),
          ),
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.pdNavy : AppColors.pdInactiveDot,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FB),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 64, color: AppColors.textMuted),
    );
  }
}
