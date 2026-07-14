import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';

/// Squelette de chargement reproduisant la mise en page réelle de la page,
/// affiché pendant que les données Firebase se chargent. Ne montre jamais
/// de faux contenu produit.
class ProductDetailsSkeleton extends StatelessWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(height: 320, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
          const SizedBox(height: 16),
          Container(height: 24, width: 220, color: Colors.white),
          const SizedBox(height: 10),
          Container(height: 14, width: 140, color: Colors.white),
          const SizedBox(height: 18),
          Row(
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(height: 48, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(height: 34, width: 160, color: Colors.white),
          const SizedBox(height: 18),
          Container(height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 16),
          Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
        ],
      ),
    );
  }
}
