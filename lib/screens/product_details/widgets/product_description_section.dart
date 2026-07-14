import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class ProductDescriptionSection extends StatefulWidget {
  final String description;

  const ProductDescriptionSection({super.key, required this.description});

  @override
  State<ProductDescriptionSection> createState() => _ProductDescriptionSectionState();
}

class _ProductDescriptionSectionState extends State<ProductDescriptionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.description.isEmpty) return const SizedBox.shrink();

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
          const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.pdDarkNavy)),
          const SizedBox(height: 10),
          Text(
            widget.description,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.pdDescriptionText),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _expanded ? 'Voir moins' : 'Voir plus',
                  style: const TextStyle(color: AppColors.pdNavy, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.pdNavy,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
