import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// Barre supérieure "Détails du produit" : dégradé navy, bouton retour,
/// titre, bouton Catalogue et bouton favori (cœur). Le comportement du
/// bouton Catalogue est injecté depuis l'écran parent (logique Firebase
/// centralisée dans CatalogueService, jamais dupliquée ici).
class ProductDetailsAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onCataloguePressed;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const ProductDetailsAppBar({
    super.key,
    required this.onBack,
    required this.onCataloguePressed,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding + 8, bottom: 12, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pdDarkNavy, AppColors.pdNavy],
        ),
      ),
      child: Row(
        children: [
          _RoundIconButton(icon: Icons.arrow_back, onTap: onBack),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Détails du produit',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          _CatalogueButton(onTap: onCataloguePressed),
          const SizedBox(width: 8),
          _RoundIconButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            onTap: onFavoritePressed,
            size: 48,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _RoundIconButton({required this.icon, required this.onTap, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _CatalogueButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CatalogueButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, color: Colors.white, size: 22),
            SizedBox(height: 2),
            Text('Catalogue', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
