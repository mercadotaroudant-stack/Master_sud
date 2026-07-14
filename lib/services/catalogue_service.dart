import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../repositories/catalogue_repository.dart';
import '../screens/catalogue/catalogue_detail_screen.dart';

/// Service unique et réutilisable pour la logique "produit → catalogue".
/// Les DEUX boutons "Catalogue" (AppBar et barre d'action basse) appellent
/// exactement la même méthode [openProductCatalogue] — aucune logique
/// dupliquée. Le lien produit → catalogue (product.catalogueId) est
/// entièrement configuré depuis le Dashboard et stocké dans Firebase.
class CatalogueService {
  CatalogueService._();

  static final CatalogueService instance = CatalogueService._();

  final CatalogueRepository _repository = FirebaseCatalogueRepository();

  Future<void> openProductCatalogue(BuildContext context, ProductModel product) async {
    final catalogueId = product.catalogueId;

    if (catalogueId == null || catalogueId.isEmpty) {
      _showMessage(context, 'Aucun catalogue associé à ce produit.');
      return;
    }

    try {
      final catalogue = await _repository.getCatalogueById(catalogueId);
      if (!context.mounted) return;

      if (catalogue == null) {
        _showMessage(context, 'Aucun catalogue associé à ce produit.');
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CatalogueDetailScreen(catalogue: catalogue)),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, 'Impossible de charger le catalogue pour le moment.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
