import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// Zone de couverture 9:16 d'une carte catalogue.
///
/// Affiche l'image réelle (BoxFit.cover, sans déformation) si
/// `coverImageUrl` est renseignée depuis le Dashboard, sinon un
/// placeholder neutre propre — jamais une icône d'image cassée.
class CatalogueCoverImage extends StatelessWidget {
  final String? imageUrl;

  const CatalogueCoverImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.trim().isEmpty) {
      return _placeholder();
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.ctCardLight,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 36, color: AppColors.ctTextSecondary),
    );
  }
}
