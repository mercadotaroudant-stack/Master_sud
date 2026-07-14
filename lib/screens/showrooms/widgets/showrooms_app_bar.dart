import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class ShowroomsAppBar extends StatelessWidget {
  final VoidCallback onBack;

  const ShowroomsAppBar({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.srBackground,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.srNavy, size: 22),
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Text(
              'Nos Showrooms',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: AppColors.srTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
