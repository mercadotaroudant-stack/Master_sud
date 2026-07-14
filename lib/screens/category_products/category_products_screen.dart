import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../localization/app_localizations.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../repositories/product_repository.dart';
import '../../widgets/product_card.dart';
import '../product_details/product_details_screen.dart';

/// صفحة منتجات فئة معيّنة (مثال مرجعي: Décoration). اسم الفئة، وصفها،
/// صورتها، وعدد/قائمة منتجاتها كلها ديناميكية بالكامل من Firebase.
/// تُفلتَر المنتجات حسب categoryId الحقيقي، ولا تُعرض إلا المنتجات
/// active = true التابعة لهذه الفئة تحديدًا.
class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

enum _LoadState { loading, loaded, error }

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ProductRepository _repository = FirebaseProductRepository();
  _LoadState _state = _LoadState.loading;
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = _LoadState.loading);
    try {
      final products = await _repository.getProductsByCategory(widget.category.id);
      if (!mounted) return;
      setState(() {
        _products = products;
        _state = _LoadState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _LoadState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    final categoryName = widget.category.name(isArabic);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppDimens.paddingLg),
          children: [
            _Breadcrumb(categoryName: categoryName),
            _CategoryInfoCard(category: widget.category, isArabic: isArabic),
            _SectionTitle(count: _state == _LoadState.loaded ? _products.length : null),
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _LoadState.loading:
        return const _ProductsGridSkeleton();
      case _LoadState.error:
        return _ErrorState(onRetry: _load);
      case _LoadState.loaded:
        if (_products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(context.tr('no_products'), style: const TextStyle(color: AppColors.textMuted)),
            ),
          );
        }
        return _ProductsGrid(
          products: _products,
          onAddPressed: (_) {},
          onViewDetails: (product) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productId: product.id, initialProduct: product),
            ),
          ),
        );
    }
  }
}

class _Breadcrumb extends StatelessWidget {
  final String categoryName;
  const _Breadcrumb({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Text(context.tr('breadcrumb_home'), style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
          ),
          Expanded(
            child: Text(
              categoryName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryInfoCard extends StatelessWidget {
  final CategoryModel category;
  final bool isArabic;

  const _CategoryInfoCard({required this.category, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: category.backgroundColor.withOpacity(0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 84,
                height: 84,
                color: category.backgroundColor,
                child: category.image.isEmpty
                    ? Center(
                        child: Text(
                          category.name(isArabic),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: category.image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const SizedBox.shrink(),
                        errorWidget: (_, __, ___) => const Icon(Icons.category_outlined, color: AppColors.textMuted),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name(isArabic),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F3265)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category.description != null && category.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      category.description!,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final int? count;
  const _SectionTitle({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count == null ? context.tr('all_products') : '${context.tr('all_products')} (${count})';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Row(
        children: [
          const Icon(Icons.grid_view_rounded, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onAddPressed;
  final ValueChanged<ProductModel> onViewDetails;

  const _ProductsGrid({required this.products, required this.onAddPressed, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 10,
          childAspectRatio: 0.45,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onAddPressed: () => onAddPressed(product),
            onViewDetails: () => onViewDetails(product),
          );
        },
      ),
    );
  }
}

class _ProductsGridSkeleton extends StatelessWidget {
  const _ProductsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 10,
          childAspectRatio: 0.45,
        ),
        itemBuilder: (_, __) => const ProductCardSkeleton(),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 44, color: AppColors.textMuted),
            const SizedBox(height: AppDimens.paddingMd),
            Text(context.tr('error_load'), style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppDimens.paddingMd),
            OutlinedButton(onPressed: onRetry, child: Text(context.tr('retry'))),
          ],
        ),
      ),
    );
  }
}
