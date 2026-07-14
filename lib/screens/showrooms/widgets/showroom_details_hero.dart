import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class ShowroomDetailsHero extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ShowroomDetailsHero({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl.isEmpty
              ? Container(color: AppColors.srNavy)
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.srNavy),
                  errorWidget: (_, __, ___) => Container(color: AppColors.srNavy),
                ),
          Container(color: AppColors.srNavy.withOpacity(0.35)),
          if (title.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 58, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
