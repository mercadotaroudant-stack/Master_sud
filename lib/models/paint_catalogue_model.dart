import 'package:cloud_firestore/cloud_firestore.dart';

/// Un catalogue de peinture (ex. "Omega Jawaher", "Master Bois") affiché
/// dans la section CATALOGUE de l'application.
///
/// Firestore : paintCatalogues/{catalogueId}
///
/// Toutes les données proviennent du Dashboard — aucune valeur n'est
/// générée ni codée en dur côté Flutter.
class PaintCatalogueModel {
  final String id;
  final String name;
  final String? coverImageUrl;
  final bool isActive;
  final int order;

  const PaintCatalogueModel({
    required this.id,
    required this.name,
    this.coverImageUrl,
    required this.isActive,
    required this.order,
  });

  factory PaintCatalogueModel.fromMap(String id, Map<String, dynamic> map) {
    final cover = map['coverImageUrl'] as String?;
    return PaintCatalogueModel(
      id: id,
      name: (map['name'] ?? '') as String,
      coverImageUrl: (cover == null || cover.trim().isEmpty) ? null : cover,
      isActive: (map['isActive'] ?? true) as bool,
      order: ((map['order'] ?? 0) as num).toInt(),
    );
  }

  factory PaintCatalogueModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return PaintCatalogueModel.fromMap(doc.id, doc.data() ?? {});
  }
}
