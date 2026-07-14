import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class ProductBottomActionBar extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final VoidCallback onCataloguePressed;
  final bool addEnabled;

  const ProductBottomActionBar({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.onCataloguePressed,
    required this.addEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.pdBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _QuantitySelector(quantity: quantity, onChanged: onQuantityChanged),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: addEnabled ? onAddToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pdDarkNavy,
                      disabledBackgroundColor: AppColors.pdOldPrice,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 20),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Ajouter au panier',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 118,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: onCataloguePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pdLightBlue,
                    foregroundColor: AppColors.pdDarkNavy,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.assignment_outlined, size: 19),
                  label: const Text('Catalogue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: 112,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.pdVariantBorder, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _StepButton(icon: Icons.remove, onTap: quantity > 1 ? () => onChanged(quantity - 1) : null),
          Expanded(
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.pdTextPrimary),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: () => onChanged(quantity + 1)),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 56,
        child: Icon(icon, size: 18, color: onTap == null ? AppColors.textMuted : AppColors.pdTextPrimary),
      ),
    );
  }
}
