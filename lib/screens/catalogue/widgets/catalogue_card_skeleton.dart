import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';

/// Squelette de carte catalogue, mêmes proportions que [CatalogueCard],
/// affiché pendant le chargement Firebase.
class CatalogueCardSkeleton extends StatelessWidget {
  const CatalogueCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(child: ColoredBox(color: Colors.white)),
            Container(
              height: 60,
              alignment: Alignment.center,
              color: Colors.white,
              child: Container(height: 16, width: 100, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
