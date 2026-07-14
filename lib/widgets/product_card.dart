import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';
import '../localization/app_localizations.dart';
import '../models/product_model.dart';

/// بطاقة المنتج الموحّدة (Single Source of Truth) — تُستخدم في كل مكان
/// يعرض منتجات بالتطبيق: صفحة منتجات الفئة، Produits Populaires، العروض،
/// نتائج البحث، وأي قسم مستقبلي. أي تعديل على التصميم هنا ينعكس تلقائيًا
/// في كل هذه الأماكن لأنها مكوّن واحد يُعاد استخدامه، وليس تصميمًا مكررًا.
///
/// كل البيانات المعروضة (الاسم، الوزن، السعر، الصورة، حالة العرض) تأتي من
/// [ProductModel] المبني بالكامل من Firestore.
class ProductCard extends StatelessWidget {
  final ProductModel product;

  /// الضغط على زر (+) الدائري: يُحضَّر هنا كبنية استدعاء فقط، ليتم ربطه
  /// لاحقًا بمنطق السلة/الطلبية الحقيقي. لا يُنفَّذ أي إجراء وهمي.
  final VoidCallback onAddPressed;

  /// الضغط على زر "Voir détails": ينتقل إلى صفحة تفاصيل المنتج الحقيقية
  /// باستخدام معرّف المستند الفعلي في Firestore (product.id).
  final VoidCallback onViewDetails;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddPressed,
    required this.onViewDetails,
  });

  static const double imageAreaHeight = 115;
  static const Color imageAreaBackground = Color(0xFFF7F8FB);
  static const Color cardBorderColor = Color(0xFFE8EAF0);

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: cardBorderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ImageArea(product: product, onAddPressed: onAddPressed),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name(isArabic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (product.weight.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          product.weight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.priceRed,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onViewDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      child: Text(
                        context.tr('view_details'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageArea extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddPressed;

  const _ImageArea({required this.product, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProductCard.imageAreaHeight,
      child: Stack(
        children: [
          Container(
            color: ProductCard.imageAreaBackground,
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(8),
            child: product.imageUrl.isEmpty
                ? const Center(
                    child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 32),
                  )
                : CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    placeholder: (_, __) => const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
                      ),
                    ),
                    errorWidget: (_, __, ___) =>
                        const Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted)),
                  ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: onAddPressed,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          if (product.isPromo)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.promo,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  context.tr('promo_label'),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// نسخة Skeleton من ProductCard بنفس المقاسات، تُستخدم أثناء تحميل البيانات
/// من Firebase حتى لا يظهر أي وميض أو اختلاف في التخطيط عند وصول البيانات.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: ProductCard.cardBorderColor, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: ProductCard.imageAreaHeight, color: AppColors.shimmerBase),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 70, height: 12, color: AppColors.shimmerBase),
                      const SizedBox(height: 6),
                      Container(width: 40, height: 10, color: AppColors.shimmerBase),
                      const SizedBox(height: 8),
                      Container(width: 55, height: 14, color: AppColors.shimmerBase),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
