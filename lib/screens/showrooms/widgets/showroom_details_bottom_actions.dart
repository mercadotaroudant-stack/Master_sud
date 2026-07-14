import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/showroom_model.dart';
import '../../../services/showroom_actions_service.dart';

class ShowroomDetailsBottomActions extends StatelessWidget {
  final ShowroomModel showroom;

  const ShowroomDetailsBottomActions({super.key, required this.showroom});

  @override
  Widget build(BuildContext context) {
    if (!showroom.hasPhone && !showroom.hasLocation) return const SizedBox.shrink();

    return Row(
      children: [
        if (showroom.hasPhone)
          Expanded(
            child: SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => ShowroomActionsService.instance.call(context, showroom),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.srNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.call_outlined, size: 20),
                label: const Text('Appeler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        if (showroom.hasPhone && showroom.hasLocation) const SizedBox(width: 12),
        if (showroom.hasLocation)
          Expanded(
            child: SizedBox(
              height: 60,
              child: OutlinedButton.icon(
                onPressed: () => ShowroomActionsService.instance.openItinerary(context, showroom),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.srNameText,
                  side: const BorderSide(color: AppColors.srNavy, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.map_outlined, size: 20),
                label: const Text('Itinéraire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
      ],
    );
  }
}
