import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../localization/app_localizations.dart';
import '../models/category_model.dart';

/// قسم CATÉGORIES في الصفحة الرئيسية.
/// - عنوان القسم بنفس مقاسات ولون التصميم المرجعي.
/// - Grid بـ 4 عناصر في كل صف، عدد صفوف غير محدود (Scroll عمودي).
/// - كل البيانات (الاسم، الصورة، اللون) تأتي بالكامل من Firebase.
class CategoriesSection extends StatelessWidget {
  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel> onTap;

  const CategoriesSection({super.key, required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(),
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: AppDimens.paddingLg),
            child: Center(
              child: Text(
                context.tr('no_categories'),
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
            ),
          )
        else
          _CategoriesGrid(categories: categories, onTap: onTap),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
      child: Text(
        context.tr('categories_title').toUpperCase(),
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F3265),
        ),
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel> onTap;

  const _CategoriesGrid({required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 100 / 120,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryCard(
            category: category,
            isArabic: isArabic,
            onTap: () => onTap(category),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isArabic;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: category.backgroundColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: category.image.isEmpty
                  ? const Icon(Icons.category_outlined, color: AppColors.textMuted)
                  : CachedNetworkImage(
                      imageUrl: category.image,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox.shrink(),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name(isArabic),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            if (category.description != null && category.description!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                category.description!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton مخصص لقسم الفئات أثناء التحميل الأول (4 أعمدة بنفس هيئة البطاقات).
class CategoriesSkeleton extends StatelessWidget {
  const CategoriesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 100 / 120,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
