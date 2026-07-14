import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../localization/app_localizations.dart';
import '../../models/catalogue_model.dart';

/// Écran affichant le catalogue réellement lié au produit (product.catalogueId).
/// Toutes les données (titre, image de couverture, PDF) proviennent de
/// Firebase — aucun catalogue fictif n'est créé ici.
class CatalogueDetailScreen extends StatelessWidget {
  final CatalogueModel catalogue;

  const CatalogueDetailScreen({super.key, required this.catalogue});

  Future<void> _openPdf(BuildContext context) async {
    if (catalogue.pdfUrl.isEmpty) return;
    final uri = Uri.tryParse(catalogue.pdfUrl);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir ce catalogue pour le moment.')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    final title = catalogue.title(isArabic);

    return Scaffold(
      backgroundColor: AppColors.pdPageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pdDarkNavy,
        foregroundColor: Colors.white,
        title: Text(title.isNotEmpty ? title : 'Catalogue'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: catalogue.coverImageUrl.isEmpty
                      ? Container(
                          color: Colors.white,
                          child: const Icon(Icons.menu_book_outlined, size: 64, color: AppColors.textMuted),
                        )
                      : CachedNetworkImage(
                          imageUrl: catalogue.coverImageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.white,
                            child: const Icon(Icons.menu_book_outlined, size: 64, color: AppColors.textMuted),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: catalogue.pdfUrl.isEmpty ? null : () => _openPdf(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pdNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Ouvrir le catalogue', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
