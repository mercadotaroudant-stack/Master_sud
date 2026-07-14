import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';

/// Carte squelette pendant le chargement des showrooms — mêmes proportions
/// que la vraie carte, aucun contenu fictif.
class ShowroomCardSkeleton extends StatelessWidget {
  const ShowroomCardSkeleton({super.key});

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
            Container(height: 248, color: Colors.white),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 200, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 14, width: 240, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(height: 30, width: 150, color: Colors.white),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Container(height: 58, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)))),
                      const SizedBox(width: 10),
                      Expanded(child: Container(height: 58, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)))),
                      const SizedBox(width: 10),
                      Expanded(child: Container(height: 58, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
