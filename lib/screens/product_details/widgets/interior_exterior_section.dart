import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// Section Intérieur / Extérieur. L'affichage dépend UNIQUEMENT des champs
/// Firebase `isInterior` / `isExterior` configurés depuis le Dashboard —
/// jamais déduits de la catégorie, du nom ou de la description du produit.
class InteriorExteriorSection extends StatelessWidget {
  final bool isInterior;
  final bool isExterior;

  const InteriorExteriorSection({super.key, required this.isInterior, required this.isExterior});

  @override
  Widget build(BuildContext context) {
    if (!isInterior && !isExterior) return const SizedBox.shrink();

    final cards = <Widget>[
      if (isInterior)
        const _UsageCard(
          icon: Icons.home_outlined,
          title: 'Intérieur',
          subtitle: 'Convient pour une utilisation en intérieur',
        ),
      if (isExterior)
        const _UsageCard(
          icon: Icons.holiday_village_outlined,
          title: 'Extérieur',
          subtitle: 'Convient pour une utilisation en extérieur',
        ),
    ];

    if (cards.length == 1) return cards.first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 360;
        if (!wide) {
          return Column(children: [cards[0], const SizedBox(height: 12), cards[1]]);
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
        );
      },
    );
  }
}

class _UsageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _UsageCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
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
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.pdLightBlue, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.pdNavy, size: 30),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w700, color: AppColors.pdDarkNavy)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.pdTextSecondary, height: 1.3)),
        ],
      ),
    );
  }
}
