import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_colors.dart';
import '../../../models/color_tryon_selection.dart';

/// Bottom sheet "Essayer cette couleur" : propose Caméra ou Mes fichiers
/// comme source de l'image sur laquelle appliquer la couleur sélectionnée.
///
/// Retourne l'[ImageSource] choisie (ou `null` si l'utilisateur annule).
Future<ImageSource?> showColorSourceBottomSheet(
  BuildContext context, {
  required ColorTryOnSelection selection,
}) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _ColorSourceBottomSheet(selection: selection),
  );
}

class _ColorSourceBottomSheet extends StatelessWidget {
  final ColorTryOnSelection selection;

  const _ColorSourceBottomSheet({required this.selection});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6D9E0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Essayer cette couleur',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: AppColors.ctTextPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selection.hexColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selection.subtitle,
                    style: const TextStyle(fontSize: 16, color: AppColors.ctTextSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SourceOptionCard(
              iconBackground: AppColors.ctNavy,
              icon: Icons.camera_alt_rounded,
              iconColor: Colors.white,
              title: 'Caméra',
              description: 'Photographier votre mur',
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(height: 13),
            _SourceOptionCard(
              iconBackground: const Color(0xFFE5B83F),
              icon: Icons.photo_library_rounded,
              iconColor: AppColors.ctNavy,
              title: 'Mes fichiers',
              description: 'Choisir une photo de votre pièce',
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOptionCard extends StatelessWidget {
  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _SourceOptionCard({
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ctSearchBackground,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.ctTextPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 15, color: AppColors.ctTextSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.ctTextSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
