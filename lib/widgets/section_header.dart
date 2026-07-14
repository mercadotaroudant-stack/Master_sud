import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

/// عنوان قسم عام (مثل PRODUITS POPULAIRES / NOS SHOWROOMS / VIDÉOS DE FORMATION)
/// مع رابط "Voir tout ›" على اليمين. يُستخدم في كل أقسام الصفحة الرئيسية
/// الديناميكية القادمة من Firebase.
class SectionHeader extends StatelessWidget {
  final String titleKey;
  final VoidCallback onSeeAllTap;

  const SectionHeader({super.key, required this.titleKey, required this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              context.tr(titleKey).toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3265),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onSeeAllTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('see_all'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F3265),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF1F3265)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
