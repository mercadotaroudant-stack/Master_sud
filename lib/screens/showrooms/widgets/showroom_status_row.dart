import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/showroom_model.dart';

/// Pilule "Ouvert maintenant" / "Fermé" — calculée dynamiquement à partir du
/// jour/heure actuels et du planning Firebase (showroom.openingSchedule).
/// Rien n'est stocké comme texte statique.
class ShowroomStatusRow extends StatelessWidget {
  final ShowroomModel showroom;

  const ShowroomStatusRow({super.key, required this.showroom});

  @override
  Widget build(BuildContext context) {
    if (!showroom.hasScheduleForToday) return const SizedBox.shrink();

    final open = showroom.isOpenNow;
    final hoursLabel = showroom.todayHoursLabel;

    return Row(
      children: [
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: open ? AppColors.srOpenGreen : AppColors.srClosedRed,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Text(
            open ? 'Ouvert maintenant' : 'Fermé',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        if (hoursLabel != null) ...[
          const SizedBox(width: 10),
          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.srTextSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              hoursLabel,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, color: AppColors.srTextSecondary),
            ),
          ),
        ],
      ],
    );
  }
}
