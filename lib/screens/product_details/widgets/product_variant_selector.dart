import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/product_variant_model.dart';

/// Sélecteur de taille/variante (ex: 5kg, 10kg, 20kg). Les libellés viennent
/// uniquement de [ProductVariant.label] (Firebase) — jamais codés en dur.
class ProductVariantSelector extends StatelessWidget {
  final List<ProductVariant> variants;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ProductVariantSelector({
    super.key,
    required this.variants,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(variants.length, (i) {
        final variant = variants[i];
        final selected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: Container(
            constraints: const BoxConstraints(minWidth: 70, minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.pdDarkNavy : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: selected ? null : Border.all(color: AppColors.pdVariantBorder, width: 1),
            ),
            child: Text(
              variant.label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.pdTextPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        );
      }),
    );
  }
}
