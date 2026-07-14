import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';

/// Squelette de carte couleur, mêmes proportions que [CatalogueColorCard].
class CatalogueColorCardSkeleton extends StatelessWidget {
  const CatalogueColorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(child: ColoredBox(color: Colors.white)),
            Container(
              height: 50,
              alignment: Alignment.center,
              color: Colors.white,
              child: Container(height: 12, width: 60, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
