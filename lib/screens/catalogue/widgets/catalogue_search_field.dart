import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// Champ de recherche partagé par la page Catalogue (recherche par nom) et
/// la page des couleurs d'un catalogue (recherche par code / nom de couleur).
class CatalogueSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const CatalogueSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.ctSearchBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 22, color: AppColors.ctTextSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 15, color: AppColors.ctTextPrimary),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 15, color: AppColors.ctTextSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
