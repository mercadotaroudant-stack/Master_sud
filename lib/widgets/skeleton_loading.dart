import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import 'categories_grid.dart';
import 'products_section.dart';
import 'showrooms_section.dart';
import 'videos_section.dart';

/// صندوق Shimmer عام يُستخدم لبناء أي شكل Skeleton (بانر، كارد، سطر نص...).
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppDimens.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Skeleton كامل للصفحة الرئيسية أثناء التحميل الأول، بنفس ترتيب
/// وهيئة الأقسام الحقيقية (Search, Menu, Banner, Categories, Products,
/// Showrooms, Videos).
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMd, vertical: AppDimens.paddingSm),
            child: const SkeletonBox(width: double.infinity, height: AppDimens.searchBarHeight, radius: AppDimens.radiusPill),
          ),
          SizedBox(
            height: AppDimens.menuCardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMd),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingSm),
              itemBuilder: (_, __) => SkeletonBox(
                width: AppDimens.menuCardWidth,
                height: AppDimens.menuCardHeight,
                radius: AppDimens.radiusMd,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingLg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMd),
            child: const SkeletonBox(width: double.infinity, height: AppDimens.bannerHeight, radius: AppDimens.radiusLg),
          ),
          const CategoriesSkeleton(),
          const ProductsSectionSkeleton(),
          const ShowroomsSectionSkeleton(),
          const VideosSectionSkeleton(),
          const SizedBox(height: AppDimens.paddingLg),
        ],
      ),
    );
  }
}
