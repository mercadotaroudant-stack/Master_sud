import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/product_characteristic_model.dart';

/// Section "Caractéristiques" : rend uniquement les paires label/valeur
/// réellement présentes dans Firebase (product.characteristics). Aucune
/// caractéristique fixe (Type, Finition, Rendement...) n'est codée en dur —
/// ce sont uniquement des exemples visuels dans la spécification produit.
class ProductCharacteristicsSection extends StatelessWidget {
  final List<ProductCharacteristic> characteristics;

  const ProductCharacteristicsSection({super.key, required this.characteristics});

  @override
  Widget build(BuildContext context) {
    if (characteristics.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Caractéristiques',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.pdDarkNavy)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth > 380;
              if (!twoColumns) {
                return Column(
                  children: characteristics
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CharacteristicRow(item: c),
                          ))
                      .toList(),
                );
              }
              return Wrap(
                runSpacing: 10,
                children: characteristics.map((c) {
                  return SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _CharacteristicRow(item: c),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CharacteristicRow extends StatelessWidget {
  final ProductCharacteristic item;

  const _CharacteristicRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 5, right: 8),
          decoration: const BoxDecoration(color: AppColors.pdNavy, shape: BoxShape.circle),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13.5, color: AppColors.pdTextPrimary),
              children: [
                TextSpan(text: '${item.label}: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: item.value, style: const TextStyle(fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
