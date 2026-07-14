import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';
import '../localization/app_localizations.dart';
import '../models/video_model.dart';
import '../widgets/section_header.dart';

/// قسم VIDÉOS DE FORMATION في الصفحة الرئيسية. Horizontal Scroll — الصور
/// المصغّرة (Thumbnails) وروابط الفيديو بالكامل من Firebase.
class VideosSection extends StatelessWidget {
  final List<VideoModel> videos;
  final ValueChanged<VideoModel> onVideoTap;
  final VoidCallback onSeeAllTap;

  const VideosSection({
    super.key,
    required this.videos,
    required this.onVideoTap,
    required this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(titleKey: 'training_videos', onSeeAllTap: onSeeAllTap),
        if (videos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: Text(context.tr('no_videos'), style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
            ),
          )
        else
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: videos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final video = videos[index];
                return _VideoCard(video: video, onTap: () => onVideoTap(video));
              },
            ),
          ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const _VideoCard({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    video.thumbnail.isEmpty
                        ? Container(color: AppColors.primary)
                        : CachedNetworkImage(
                            imageUrl: video.thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppColors.shimmerBase),
                            errorWidget: (_, __, ___) => Container(color: AppColors.primary),
                          ),
                    Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 26),
                      ),
                    ),
                    if (video.duration.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            video.duration,
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    if (video.description != null && video.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        video.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton لقسم الفيديوهات أثناء التحميل الأول.
class VideosSectionSkeleton extends StatelessWidget {
  const VideosSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => Container(
          width: 220,
          height: 190,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
