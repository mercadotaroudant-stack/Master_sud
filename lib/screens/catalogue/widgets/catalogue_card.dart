import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/paint_catalogue_model.dart';
import 'catalogue_cover_image.dart';

/// Carte catalogue de la grille principale : couverture 9:16 façon
/// Reels/Stories + titre centré en dessous. Toutes les données (image,
/// nom) proviennent du Dashboard/Firebase.
class CatalogueCard extends StatelessWidget {
  final PaintCatalogueModel catalogue;
  final VoidCallback onTap;

  const CatalogueCard({super.key, required this.catalogue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CatalogueCoverImage(imageUrl: catalogue.coverImageUrl),
              ),
              Container(
                height: 60,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white,
                child: Text(
                  catalogue.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ctTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
