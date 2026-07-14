import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class ShowroomAboutSection extends StatelessWidget {
  final String description;

  const ShowroomAboutSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    if (description.trim().isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À propos de notre showroom',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.srNameText),
        ),
        const SizedBox(height: 13),
        Text(
          description,
          style: const TextStyle(fontSize: 18, height: 1.6, color: AppColors.srTextSecondary),
        ),
      ],
    );
  }
}
