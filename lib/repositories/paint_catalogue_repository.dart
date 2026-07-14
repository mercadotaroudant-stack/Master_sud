import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/catalogue_color_model.dart';
import '../models/paint_catalogue_model.dart';
import '../services/firebase_service.dart';

/// Accès Firestore pour la section CATALOGUE (catalogues de peinture et
/// leurs couleurs). Le Dashboard est la seule source de vérité : Flutter ne
/// fait que lire et afficher, en temps réel, via des streams Firestore.
abstract class PaintCatalogueRepository {
  /// Tous les catalogues actifs, triés par ordre d'affichage.
  Stream<List<PaintCatalogueModel>> streamActiveCatalogues();

  /// Un seul catalogue par son identifiant (temps réel, pour refléter les
  /// changements faits depuis le Dashboard — nom, image de couverture...).
  Stream<PaintCatalogueModel?> streamCatalogueById(String catalogueId);

  /// Les couleurs actives d'un catalogue donné, triées par ordre d'affichage.
  Stream<List<CatalogueColorModel>> streamActiveColors(String catalogueId);
}

class FirebasePaintCatalogueRepository implements PaintCatalogueRepository {
  final FirebaseFirestore _db = FirebaseService.instance.firestore;

  CollectionReference<Map<String, dynamic>> get _catalogues =>
      _db.collection(AppConfig.collectionPaintCatalogues);

  @override
  Stream<List<PaintCatalogueModel>> streamActiveCatalogues() {
    return _catalogues
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(PaintCatalogueModel.fromDoc).toList());
  }

  @override
  Stream<PaintCatalogueModel?> streamCatalogueById(String catalogueId) {
    return _catalogues.doc(catalogueId).snapshots().map(
          (doc) => doc.exists ? PaintCatalogueModel.fromDoc(doc) : null,
        );
  }

  @override
  Stream<List<CatalogueColorModel>> streamActiveColors(String catalogueId) {
    return _catalogues
        .doc(catalogueId)
        .collection(AppConfig.subcollectionCatalogueColors)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CatalogueColorModel.fromDoc).toList());
  }
}
