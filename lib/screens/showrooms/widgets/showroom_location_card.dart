import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/showroom_model.dart';
import '../../../services/showroom_actions_service.dart';

class ShowroomLocationCard extends StatelessWidget {
  final ShowroomModel showroom;

  const ShowroomLocationCard({super.key, required this.showroom});

  @override
  Widget build(BuildContext context) {
    if (!showroom.hasLocation) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.srBackground, borderRadius: BorderRadius.circular(17)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.location_on, size: 20, color: AppColors.srDetailsRed),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        showroom.address.isNotEmpty ? showroom.address : showroom.city,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.srNameText),
                      ),
                    ),
                  ],
                ),
                if (showroom.city.isNotEmpty && showroom.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    showroom.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, color: AppColors.srTextSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => ShowroomActionsService.instance.openItinerary(context, showroom),
            customBorder: const CircleBorder(),
            child: Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.srNavy, shape: BoxShape.circle),
              child: const Icon(Icons.map_outlined, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
