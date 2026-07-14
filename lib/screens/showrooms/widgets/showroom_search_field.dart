import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class ShowroomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const ShowroomSearchField({super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.srBackground,
        border: Border.all(color: AppColors.srSearchBorder, width: 1),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 26, color: AppColors.srTextSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 16, color: AppColors.srTextPrimary),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Rechercher...',
                hintStyle: TextStyle(fontSize: 16, color: AppColors.srTextSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
