import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/video_model.dart';
import 'formation_thumbnail.dart';

/// Carte vidéo de la grille Formation : vignette + bouton lecture centré +
/// badge durée + titre. Toutes les données proviennent du Dashboard/Firebase.
class FormationCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const FormationCard({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fmCardBg,
      borderRadius: BorderRadius.circular(19),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.fmCardBg,
            borderRadius: BorderRadius.circular(19),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FormationThumbnail(imageUrl: video.thumbnail),
                    // Bouton lecture centré
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.94),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.fmIconNavy,
                          size: 26,
                        ),
                      ),
                    ),
                    // Badge durée
                    if (video.duration.isNotEmpty)
                      Positioned(
                        right: 11,
                        bottom: 11,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.fmDurationBg.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            video.duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 30,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.fmTitle,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
