import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// Fil d'Ariane "Accueil › [Catégorie] › [Nom produit]". La catégorie et le
/// nom du produit proviennent entièrement de Firebase (relation
/// produit/catégorie), rien n'est codé en dur.
class ProductBreadcrumb extends StatelessWidget {
  final String? categoryName;
  final String productName;
  final VoidCallback onHomeTap;

  const ProductBreadcrumb({
    super.key,
    required this.categoryName,
    required this.productName,
    required this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    const secondaryStyle = TextStyle(color: AppColors.pdTextSecondary, fontSize: 13.5);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          GestureDetector(
            onTap: onHomeTap,
            child: const Text(
              'Accueil',
              style: TextStyle(color: AppColors.pdNavy, fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
          if (categoryName != null && categoryName!.isNotEmpty) ...[
            const _Chevron(),
            Flexible(
              child: Text(categoryName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: secondaryStyle),
            ),
          ],
          const _Chevron(),
          Flexible(
            child: Text(productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: secondaryStyle),
          ),
        ],
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Icon(Icons.chevron_right, size: 16, color: AppColors.pdTextSecondary),
    );
  }
}
