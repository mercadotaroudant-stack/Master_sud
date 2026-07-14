import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/showroom_model.dart';
import 'showroom_action_buttons.dart';
import 'showroom_status_row.dart';

/// Carte showroom complète, fidèle à la maquette MASTER SUD fournie.
/// Toutes les données affichées (image, badge, nom, adresse, horaires,
/// téléphone, localisation) proviennent uniquement de [ShowroomModel]
/// (Firebase) — rien n'est codé en dur.
class ShowroomCard extends StatelessWidget {
  final ShowroomModel showroom;
  final VoidCallback onViewDetails;

  const ShowroomCard({super.key, required this.showroom, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.srCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ImageHeader(showroom: showroom),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.location_on, size: 20, color: AppColors.srClosedRed),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        showroom.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.srNameText),
                      ),
                    ),
                  ],
                ),
                if (showroom.address.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.home_outlined, size: 18, color: AppColors.srTextSecondary),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          showroom.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, color: AppColors.srTextSecondary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                ShowroomStatusRow(showroom: showroom),
                const SizedBox(height: 20),
                ShowroomActionButtons(showroom: showroom, onViewDetails: onViewDetails),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageHeader extends StatelessWidget {
  final ShowroomModel showroom;

  const _ImageHeader({required this.showroom});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 248,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          showroom.image.isEmpty
              ? Container(color: AppColors.srNavy)
              : CachedNetworkImage(
                  imageUrl: showroom.image,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.srNavy),
                  errorWidget: (_, __, ___) => Container(color: AppColors.srNavy),
                ),
          Container(color: AppColors.srNavy.withOpacity(0.55)),
          if (showroom.hasBadge)
            Positioned(
              top: 18,
              right: 18,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 19),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.srGold,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Text(
                  showroom.badgeLabel!.toUpperCase(),
                  style: const TextStyle(color: AppColors.srBadgeText, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 27,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showroom.city.isNotEmpty)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      showroom.city,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.75),
                        height: 1,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: AppColors.srClosedRed),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        showroom.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
