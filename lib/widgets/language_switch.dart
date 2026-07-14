import 'package:flutter/material.dart';

/// Segmented Control حديث لتبديل اللغة (عربي / Français).
/// المقاسات: 190 x 48، Border Radius: 24، Background: #F5F5F5
class LanguageSwitch extends StatelessWidget {
  final bool isArabic;
  final ValueChanged<bool> onChanged; // true = عربي, false = فرنسي

  const LanguageSwitch({
    super.key,
    required this.isArabic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1F3265),
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _SwitchLabel(
                  text: 'Français',
                  selected: !isArabic,
                  onTap: () => onChanged(false),
                ),
              ),
              Expanded(
                child: _SwitchLabel(
                  text: 'عربي',
                  selected: isArabic,
                  onTap: () => onChanged(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwitchLabel extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SwitchLabel({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}
