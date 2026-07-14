import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings_keys.dart';
import '../localization/app_localizations.dart';

class MenuItemData {
  final String labelKey;
  final IconData icon;
  final VoidCallback onTap;

  const MenuItemData({required this.labelKey, required this.icon, required this.onTap});
}

/// القائمة الأفقية القابلة للسحب (بديل Bottom Navigation) بنفس مقاسات
/// وألوان التصميم المرجعي. تعرض جميع العناصر حتى لو زاد عددها عن عرض الشاشة.
class HorizontalMenu extends StatelessWidget {
  final List<MenuItemData> items;

  const HorizontalMenu({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.menuCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMd),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingSm),
        itemBuilder: (context, index) {
          final item = items[index];
          return _MenuCard(item: item);
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuItemData item;
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        onTap: item.onTap,
        child: Container(
          width: AppDimens.menuCardWidth,
          height: AppDimens.menuCardHeight,
          padding: const EdgeInsets.all(AppDimens.paddingSm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr(item.labelKey),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
