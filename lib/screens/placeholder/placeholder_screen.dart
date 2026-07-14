import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings_keys.dart';
import '../../localization/app_localizations.dart';

/// شاشة مؤقتة (Placeholder) لكل الصفحات الداخلية التي لم تُبنَ بعد
/// (Produits, Catalogue, Showrooms, Papier peint, Formation, Devis, Commande).
/// سيتم استبدالها بصفحات كاملة ومرتبطة بـ Firebase في المراحل القادمة.
class PlaceholderScreen extends StatelessWidget {
  /// مفتاح ترجمة للعنوان (يُستخدم لعناصر القائمة الثابتة مثل Produits/Devis).
  final String? titleKey;

  /// عنوان جاهز (نصّ ديناميكي قادم من Firebase، مثل اسم Category بلغته الحالية).
  /// إذا تم تمريره، له الأولوية على [titleKey].
  final String? title;

  const PlaceholderScreen({super.key, this.titleKey, this.title}) : assert(titleKey != null || title != null);

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? context.tr(titleKey!);
    return Scaffold(
      appBar: AppBar(title: Text(resolvedTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded, size: 56, color: AppColors.textMuted),
              const SizedBox(height: AppDimens.paddingMd),
              Text(
                context.tr(K.comingSoon),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppDimens.paddingSm),
              Text(
                context.tr(K.comingSoonDesc),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimens.paddingLg),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr(K.backHome)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
