import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// État vide / erreur de la page Formation.
class FormationEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const FormationEmptyState({
    super.key,
    this.icon = Icons.play_circle_outline_rounded,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.fmTextSecondary),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.fmTextSecondary, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
