import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/showroom_model.dart';
import '../../../services/showroom_actions_service.dart';

class ShowroomActionButtons extends StatelessWidget {
  final ShowroomModel showroom;
  final VoidCallback? onViewDetails;

  const ShowroomActionButtons({super.key, required this.showroom, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showroom.hasPhone)
          Expanded(
            flex: 3,
            child: _ActionButton(
              label: 'Appeler',
              icon: Icons.call_outlined,
              background: AppColors.srNavy,
              foreground: Colors.white,
              bordered: false,
              onTap: () => ShowroomActionsService.instance.call(context, showroom),
            ),
          ),
        if (showroom.hasPhone) const SizedBox(width: 10),
        if (showroom.hasLocation)
          Expanded(
            flex: 3,
            child: _ActionButton(
              label: 'Itinéraire',
              icon: Icons.map_outlined,
              background: Colors.white,
              foreground: AppColors.srNameText,
              bordered: true,
              onTap: () => ShowroomActionsService.instance.openItinerary(context, showroom),
            ),
          ),
        if (showroom.hasLocation && onViewDetails != null) const SizedBox(width: 10),
        if (onViewDetails != null)
          Expanded(
            flex: 3,
            child: _ActionButton(
              label: 'Voir détails',
              icon: Icons.info_outline,
              background: Colors.white,
              foreground: AppColors.srNameText,
              bordered: true,
              onTap: onViewDetails!,
            ),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final bool bordered;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.bordered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: bordered ? const BorderSide(color: AppColors.srBorder, width: 1) : BorderSide.none,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
