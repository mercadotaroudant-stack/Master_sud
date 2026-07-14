import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/showroom_model.dart';

/// Carte horaires : affiche le planning hebdomadaire regroupé (ex: "Lundi -
/// Samedi : 08:00 - 18:30", "Dimanche : Fermé"), entièrement calculé depuis
/// [ShowroomModel.groupedSchedule] (Firebase). Rien n'est codé en dur.
class ShowroomHoursCard extends StatelessWidget {
  final ShowroomModel showroom;

  const ShowroomHoursCard({super.key, required this.showroom});

  @override
  Widget build(BuildContext context) {
    final groups = showroom.groupedSchedule;

    if (groups.isEmpty) {
      // Pas de planning structuré : on retombe sur le texte libre s'il existe.
      final fallback = showroom.openingHours;
      if (fallback == null || fallback.trim().isEmpty) return const SizedBox.shrink();
      return _CardShell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.access_time_rounded, size: 20, color: AppColors.srNameText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(fallback,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.srNameText)),
            ),
          ],
        ),
      );
    }

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(groups.length, (i) {
          final group = groups[i];
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (i == 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 2, right: 8),
                    child: Icon(Icons.access_time_rounded, size: 20, color: AppColors.srNameText),
                  )
                else
                  const SizedBox(width: 28),
                Expanded(
                  child: group.isClosed
                      ? Text(
                          '${group.daysLabel} : Fermé',
                          style: const TextStyle(fontSize: 16, color: AppColors.srDetailsRed, fontWeight: FontWeight.w500),
                        )
                      : Text(
                          '${group.daysLabel} : ${group.hoursLabel}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.srNameText),
                        ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.srBackground, borderRadius: BorderRadius.circular(17)),
      child: child,
    );
  }
}
