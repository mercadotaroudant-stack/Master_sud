import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج أساسي للكتالوجات (ملفات PDF). المجموعة في Firestore: catalogues
class CatalogueModel {
  final String id;
  final String titleAr;
  final String titleFr;
  final String coverImageUrl;
  final String pdfUrl;

  const CatalogueModel({
    required this.id,
    required this.titleAr,
    required this.titleFr,
    required this.coverImageUrl,
    required this.pdfUrl,
  });

  String title(bool isArabic) => isArabic ? titleAr : titleFr;

  factory CatalogueModel.fromMap(String id, Map<String, dynamic> map) {
    return CatalogueModel(
      id: id,
      titleAr: (map['titleAr'] ?? '') as String,
      titleFr: (map['titleFr'] ?? '') as String,
      coverImageUrl: (map['coverImageUrl'] ?? '') as String,
      pdfUrl: (map['pdfUrl'] ?? '') as String,
    );
  }

  factory CatalogueModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CatalogueModel.fromMap(doc.id, doc.data() ?? {});
  }
}
