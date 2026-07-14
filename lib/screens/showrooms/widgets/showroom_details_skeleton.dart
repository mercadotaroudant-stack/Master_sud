import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';

class ShowroomDetailsSkeleton extends StatelessWidget {
  const ShowroomDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(height: 240, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 22, width: 220, color: Colors.white),
                const SizedBox(height: 10),
                Container(height: 16, width: 260, color: Colors.white),
                const SizedBox(height: 22),
                Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17))),
                const SizedBox(height: 12),
                Container(height: 96, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17))),
                const SizedBox(height: 12),
                Container(height: 92, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
