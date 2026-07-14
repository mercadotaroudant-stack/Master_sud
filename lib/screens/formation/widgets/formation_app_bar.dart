import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// Barre supérieure de la page Formation : bouton retour 48x48 + titre,
/// dans le même esprit que les autres pages internes (Catalogue, Showrooms).
class FormationAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const FormationAppBar({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.fmBackground,
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
                color: AppColors.fmBackButtonBg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.fmIconNavy, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.fmTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
