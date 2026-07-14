import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import 'full_screen_image_viewer.dart';

/// Section "Exemples d'application" : liste horizontale défilante d'images
/// venant de Firebase (product.applicationImages). Masquée entièrement s'il
/// n'y a aucune image — jamais de photos de démonstration.
class ApplicationExamplesSection extends StatelessWidget {
  final List<String> images;

  const ApplicationExamplesSection({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 12),
          child: Text("Exemples d'application",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.pdDarkNavy)),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageViewer(images: images, initialIndex: i),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: images[i],
                    width: 165,
                    height: 160,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(width: 165, color: AppColors.shimmerBase),
                    errorWidget: (_, __, ___) => Container(
                      width: 165,
                      color: AppColors.shimmerBase,
                      child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
