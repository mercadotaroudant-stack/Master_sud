import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';

/// Squelette de carte vidéo Formation, mêmes proportions que [FormationCard],
/// affiché pendant le premier chargement Firebase.
class FormationCardSkeleton extends StatelessWidget {
  const FormationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(flex: 70, child: ColoredBox(color: Colors.white)),
            Expanded(
              flex: 30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(height: 15, width: 120, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
