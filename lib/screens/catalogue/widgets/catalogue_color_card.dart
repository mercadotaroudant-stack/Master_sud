import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/catalogue_color_model.dart';

/// Carte couleur : couleur réelle (hexColor Firebase) en haut, code
/// centré en bas sur fond blanc. Chaque carte possède son propre bouton
/// caméra (haut-droite) pour lancer l'essai de couleur sur cette couleur
/// précise.
class CatalogueColorCard extends StatelessWidget {
  final CatalogueColorModel color;
  final VoidCallback onCameraTap;

  const CatalogueColorCard({super.key, required this.color, required this.onCameraTap});

  @override
  Widget build(BuildContext context) {
    final swatch = color.color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                swatch != null
                    ? ColoredBox(color: swatch)
                    : Container(
                        color: AppColors.ctCardLight,
                        alignment: Alignment.center,
                        child: const Icon(Icons.format_color_reset_outlined, size: 26, color: AppColors.ctTextSecondary),
                      ),
                Positioned(
                  top: 11,
                  right: 11,
                  child: _CameraButton(onTap: onCameraTap),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            alignment: Alignment.center,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              color.code,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ctTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CameraButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: const Icon(Icons.camera_alt_rounded, size: 21, color: AppColors.ctNavy),
        ),
      ),
    );
  }
}
