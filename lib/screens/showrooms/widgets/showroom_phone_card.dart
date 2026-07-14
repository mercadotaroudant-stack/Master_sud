import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/showroom_model.dart';
import '../../../services/showroom_actions_service.dart';

class ShowroomPhoneCard extends StatelessWidget {
  final ShowroomModel showroom;

  const ShowroomPhoneCard({super.key, required this.showroom});

  @override
  Widget build(BuildContext context) {
    if (!showroom.hasPhone) return const SizedBox.shrink();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.srBackground, borderRadius: BorderRadius.circular(17)),
      child: Row(
        children: [
          const Icon(Icons.call_outlined, size: 22, color: AppColors.srNameText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              showroom.phone!,
              style: const TextStyle(fontSize: 19, color: Color(0xFF303644), fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _CircleActionButton(
            icon: Icons.call,
            onTap: () => ShowroomActionsService.instance.call(context, showroom),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 54,
        height: 54,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: AppColors.srNavy, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
