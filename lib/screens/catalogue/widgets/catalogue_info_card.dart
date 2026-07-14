import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/paint_catalogue_model.dart';
import 'catalogue_cover_image.dart';

/// Carte d'information affichée en haut de la page des couleurs d'un
/// catalogue : miniature de couverture + nom + nombre de couleurs.
class CatalogueInfoCard extends StatelessWidget {
  final PaintCatalogueModel catalogue;
  final int colorCount;

  const CatalogueInfoCard({super.key, required this.catalogue, required this.colorCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.ctCardLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CatalogueCoverImage(imageUrl: catalogue.coverImageUrl),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catalogue.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ctTextPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  colorCount == 0
                      ? 'Aucune couleur disponible'
                      : '$colorCount couleur${colorCount > 1 ? 's' : ''} disponible${colorCount > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 13, color: AppColors.ctTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
