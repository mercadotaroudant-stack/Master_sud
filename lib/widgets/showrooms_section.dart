import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';
import '../localization/app_localizations.dart';
import '../models/showroom_model.dart';
import '../widgets/section_header.dart';

/// قسم NOS SHOWROOMS في الصفحة الرئيسية. Horizontal Scroll — البيانات
/// (بما فيها صورة الخلفية) بالكامل من Firebase.
class ShowroomsSection extends StatelessWidget {
  final List<ShowroomModel> showrooms;
  final ValueChanged<ShowroomModel> onShowroomTap;
  final VoidCallback onSeeAllTap;

  const ShowroomsSection({
    super.key,
    required this.showrooms,
    required this.onShowroomTap,
    required this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(titleKey: 'our_showrooms', onSeeAllTap: onSeeAllTap),
        if (showrooms.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: Text(context.tr('no_showrooms'), style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: showrooms.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final showroom = showrooms[index];
                return _ShowroomCard(showroom: showroom, onTap: () => onShowroomTap(showroom));
              },
            ),
          ),
      ],
    );
  }
}

class _ShowroomCard extends StatelessWidget {
  final ShowroomModel showroom;
  final VoidCallback onTap;

  const _ShowroomCard({required this.showroom, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 220,
        height: 140,
        child: Stack(
          fit: StackFit.expand,
          children: [
            showroom.image.isEmpty
                ? Container(color: AppColors.primary)
                : CachedNetworkImage(
                    imageUrl: showroom.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.shimmerBase),
                    errorWidget: (_, __, ___) => Container(color: AppColors.primary),
                  ),
            // Overlay أسود شفاف بنسبة 40%
            Container(color: Colors.black.withOpacity(0.40)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    showroom.city,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          showroom.address,
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 120,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                      child: Text(
                        context.tr('view_details'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
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

/// Skeleton لقسم الـ Showrooms أثناء التحميل الأول.
class ShowroomsSectionSkeleton extends StatelessWidget {
  const ShowroomsSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => Container(
          width: 220,
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
