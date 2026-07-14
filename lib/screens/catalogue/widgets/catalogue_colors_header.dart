import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// En-tête de la page "Couleurs du catalogue" : bouton retour + nom du
/// catalogue uniquement. Pas de carte d'information, pas de bouton caméra
/// global — le caméra appartient à chaque carte couleur.
class CatalogueColorsHeader extends StatelessWidget {
  final String catalogueName;
  final VoidCallback onBack;

  const CatalogueColorsHeader({super.key, required this.catalogueName, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.ctBackground,
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ctSearchBackground,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.ctNavy, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              catalogueName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.ctTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
