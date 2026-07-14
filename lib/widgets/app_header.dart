import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings_keys.dart';
import '../localization/app_localizations.dart';

/// Header الصفحة الرئيسية: Menu + Logo + اسم التطبيق + زر Devis + زر Commande.
class AppHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onDevisTap;
  final VoidCallback onCommandeTap;

  const AppHeader({
    super.key,
    required this.onMenuTap,
    required this.onDevisTap,
    required this.onCommandeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMd,
          vertical: AppDimens.paddingSm,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                AppAssets.logoUrl,
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.format_paint_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppDimens.paddingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr(K.appName).toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    context.tr(K.tagline),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.paddingSm),
            _HeaderButton(label: context.tr(K.devis), onTap: onDevisTap, filled: false),
            const SizedBox(width: AppDimens.paddingXs),
            _HeaderButton(label: context.tr(K.commande), onTap: onCommandeTap, filled: true),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _HeaderButton({required this.label, required this.onTap, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            border: filled ? null : Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
