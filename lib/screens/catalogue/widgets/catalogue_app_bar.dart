import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// Barre supérieure commune aux pages de la section CATALOGUE : bouton
/// retour 48x48 + titre, dans le même esprit que les autres pages internes
/// de l'application (ex. Nos Showrooms).
class CatalogueAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const CatalogueAppBar({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ctCardLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.ctNavy, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 23,
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
