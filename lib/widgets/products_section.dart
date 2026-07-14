import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../localization/app_localizations.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/section_header.dart';

/// قسم PRODUITS POPULAIRES في الصفحة الرئيسية.
/// Horizontal Scroll فقط (ليس Grid) — يستعمل بطاقة المنتج الموحّدة
/// [ProductCard] (نفس التصميم المستخدم في صفحة منتجات الفئة وكل مكان آخر).
class ProductsSection extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onAddPressed;
  final ValueChanged<ProductModel> onViewDetails;
  final VoidCallback onSeeAllTap;

  const ProductsSection({
    super.key,
    required this.products,
    required this.onAddPressed,
    required this.onViewDetails,
    required this.onSeeAllTap,
  });

  static const double _cardWidth = 155;
  static const double _cardHeight = 250;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(titleKey: 'popular_products', onSeeAllTap: onSeeAllTap),
        if (products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: Text(context.tr('no_products'), style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
            ),
          )
        else
          SizedBox(
            height: _cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return SizedBox(
                  width: _cardWidth,
                  child: ProductCard(
                    product: product,
                    onAddPressed: () => onAddPressed(product),
                    onViewDetails: () => onViewDetails(product),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Skeleton لقسم المنتجات أثناء التحميل الأول — بنفس مقاسات [ProductCard].
class ProductsSectionSkeleton extends StatelessWidget {
  const ProductsSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProductsSection._cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => const SizedBox(
          width: ProductsSection._cardWidth,
          child: ProductCardSkeleton(),
        ),
      ),
    );
  }
}
