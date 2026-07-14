import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class ShowroomDetailsAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const ShowroomDetailsAppBar({
    super.key,
    required this.onBack,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          _SquareIconButton(icon: Icons.arrow_back, onTap: onBack),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Détails du showroom',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: AppColors.srTextPrimary),
            ),
          ),
          const SizedBox(width: 8),
          _SquareIconButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            onTap: onFavoritePressed,
            iconColor: isFavorite ? AppColors.srDetailsRed : AppColors.srNavy,
          ),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _SquareIconButton({required this.icon, required this.onTap, this.iconColor = AppColors.srNavy});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.srBackground, borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: iconColor, size: 26),
      ),
    );
  }
}
