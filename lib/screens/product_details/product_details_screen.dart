import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/cart_item_model.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/product_variant_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/product_repository.dart';
import '../../services/catalogue_service.dart';
import 'widgets/application_examples_section.dart';
import 'widgets/interior_exterior_section.dart';
import 'widgets/product_bottom_action_bar.dart';
import 'widgets/product_breadcrumb.dart';
import 'widgets/product_characteristics_section.dart';
import 'widgets/product_description_section.dart';
import 'widgets/product_details_app_bar.dart';
import 'widgets/product_details_skeleton.dart';
import 'widgets/product_image_gallery.dart';
import 'widgets/product_price_section.dart';
import 'widgets/product_variant_selector.dart';

/// Page "Détails du produit" MASTER SUD — entièrement pilotée par Firebase.
/// Aucune donnée produit fictive : tout (images, variantes, prix, promo,
/// stock, description, caractéristiques, intérieur/extérieur, exemples
/// d'application, catalogue lié) provient de Firestore et est configurable
/// depuis le Dashboard.
class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final ProductModel? initialProduct;

  const ProductDetailsScreen({super.key, required this.productId, this.initialProduct});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

enum _LoadState { loading, loaded, error, notFound }

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductRepository _productRepository = FirebaseProductRepository();
  final CategoryRepository _categoryRepository = FirebaseCategoryRepository();

  _LoadState _state = _LoadState.loading;
  ProductModel? _product;
  CategoryModel? _category;

  int _selectedVariantIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _applyProduct(widget.initialProduct!);
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _state = _LoadState.loading);
    try {
      final product = await _productRepository.getProductById(widget.productId);
      if (!mounted) return;
      if (product == null) {
        setState(() => _state = _LoadState.notFound);
        return;
      }
      _applyProduct(product);
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _LoadState.error);
    }
  }

  void _applyProduct(ProductModel product) {
    setState(() {
      _product = product;
      _state = _LoadState.loaded;
      _selectedVariantIndex = 0;
      _quantity = 1;
    });
    _loadCategory(product.categoryId);
  }

  Future<void> _loadCategory(String? categoryId) async {
    if (categoryId == null || categoryId.isEmpty) return;
    try {
      final category = await _categoryRepository.getCategoryById(categoryId);
      if (!mounted) return;
      setState(() => _category = category);
    } catch (_) {
      // Le fil d'Ariane reste simplement sans catégorie en cas d'échec silencieux.
    }
  }

  ProductVariant get _selectedVariant {
    final variants = _product!.effectiveVariants;
    final index = _selectedVariantIndex.clamp(0, variants.length - 1);
    return variants[index];
  }

  void _onAddToCart() {
    final product = _product;
    if (product == null) return;

    final variant = _selectedVariant;
    if (!variant.inStock) return;
    if (_quantity < 1) return;

    final images = product.galleryImages;

    context.read<CartProvider>().addItem(
          CartItemModel(
            productId: product.id,
            productName: product.nameFr.isNotEmpty ? product.nameFr : product.nameAr,
            selectedVariantId: variant.id.isNotEmpty ? variant.id : null,
            selectedVariantLabel: variant.label.isNotEmpty ? variant.label : null,
            unitPrice: variant.effectivePrice,
            quantity: _quantity,
            imageUrl: images.isNotEmpty ? images.first : '',
          ),
        );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produit ajouté au panier.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pdPageBackground,
      body: Column(
        children: [
          ProductDetailsAppBar(
            onBack: () => Navigator.of(context).maybePop(),
            onCataloguePressed: () {
              if (_product != null) {
                CatalogueService.instance.openProductCatalogue(context, _product!);
              }
            },
            isFavorite: _product != null && context.watch<FavoritesProvider>().isFavorite('product', _product!.id),
            onFavoritePressed: () {
              if (_product != null) context.read<FavoritesProvider>().toggle('product', _product!.id);
            },
          ),
          Expanded(child: _buildBody(context)),
        ],
      ),
      bottomNavigationBar: _state == _LoadState.loaded && _product != null
          ? ProductBottomActionBar(
              quantity: _quantity,
              onQuantityChanged: (q) => setState(() => _quantity = q < 1 ? 1 : q),
              onAddToCart: _onAddToCart,
              onCataloguePressed: () => CatalogueService.instance.openProductCatalogue(context, _product!),
              addEnabled: _selectedVariant.inStock,
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _LoadState.loading:
        return const ProductDetailsSkeleton();
      case _LoadState.error:
        return _MessageState(
          icon: Icons.wifi_off_rounded,
          message: 'Impossible de charger le produit.',
          actionLabel: 'Réessayer',
          onAction: _load,
        );
      case _LoadState.notFound:
        return _MessageState(
          icon: Icons.search_off_rounded,
          message: 'Produit introuvable',
          actionLabel: 'Retour',
          onAction: () => Navigator.of(context).maybePop(),
        );
      case _LoadState.loaded:
        return _buildContent(context, _product!);
    }
  }

  Widget _buildContent(BuildContext context, ProductModel product) {
    final variants = product.effectiveVariants;
    final selected = _selectedVariant;
    final productName = product.nameFr.isNotEmpty ? product.nameFr : product.nameAr;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ProductBreadcrumb(
            categoryName: _category?.titleFr.isNotEmpty == true ? _category!.titleFr : _category?.title,
            productName: productName,
            onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ProductImageGallery(images: product.galleryImages, showPromoBadge: product.isPromo),
                ),
                const SizedBox(height: 16),
                Text(
                  productName,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.pdDarkNavy, height: 1.2),
                ),
                if ((selected.reference ?? product.reference) != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Référence: ${selected.reference ?? product.reference}',
                    style: const TextStyle(fontSize: 13.5, color: AppColors.pdTextSecondary),
                  ),
                ],
                if (variants.length > 1) ...[
                  const SizedBox(height: 18),
                  const Text('Taille', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.pdTextSecondary)),
                  const SizedBox(height: 10),
                  ProductVariantSelector(
                    variants: variants,
                    selectedIndex: _selectedVariantIndex,
                    onSelected: (i) => setState(() => _selectedVariantIndex = i),
                  ),
                ],
                const SizedBox(height: 18),
                ProductPriceSection(variant: selected),
                const SizedBox(height: 12),
                ProductStockStatus(inStock: selected.inStock),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InteriorExteriorSection(isInterior: product.isInterior, isExterior: product.isExterior),
          ),
          if (product.isInterior || product.isExterior) const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProductDescriptionSection(description: product.description(false)),
          ),
          if (product.description(false).isNotEmpty) const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProductCharacteristicsSection(characteristics: product.characteristics),
          ),
          if (product.characteristics.isNotEmpty) const SizedBox(height: 18),
          ApplicationExamplesSection(images: product.applicationImages),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.pdTextSecondary, fontSize: 15)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
