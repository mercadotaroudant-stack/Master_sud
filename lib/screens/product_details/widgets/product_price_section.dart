import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/product_model.dart';
import '../../../models/product_variant_model.dart';

/// Zone "Prix" : prix courant (rouge), prix barré + badge de réduction si
/// une promotion valide existe sur le variant sélectionné. Rien n'est
/// calculé arbitrairement : le badge n'apparaît que si Firebase fournit un
/// promoPrice strictement inférieur au prix normal.
class ProductPriceSection extends StatelessWidget {
  final ProductVariant variant;

  const ProductPriceSection({super.key, required this.variant});

  @override
  Widget build(BuildContext context) {
    final hasPromo = variant.hasValidPromo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prix', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: AppColors.pdTextSecondary)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              ProductModel.formatPrice(variant.effectivePrice),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.pdPriceRed),
            ),
            if (hasPromo) ...[
              const SizedBox(width: 10),
              Text(
                ProductModel.formatPrice(variant.price),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.pdOldPrice,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 10),
              if (variant.discountPercent != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pdDiscountBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '-${variant.discountPercent}%',
                    style: const TextStyle(color: AppColors.pdPriceRed, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Statut de stock du variant sélectionné.
class ProductStockStatus extends StatelessWidget {
  final bool inStock;

  const ProductStockStatus({super.key, required this.inStock});

  @override
  Widget build(BuildContext context) {
    final color = inStock ? AppColors.pdSuccessGreen : AppColors.error;
    final label = inStock ? 'En stock' : 'Rupture de stock';

    return Row(
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
