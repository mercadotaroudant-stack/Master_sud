import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج بيانات لصور الـ Banner Slider في الصفحة الرئيسية.
/// المجموعة في Firestore: banners
class BannerModel {
  final String id;
  final String imageUrl;
  final String? title;
  final String? linkTarget; // اسم صفحة/مسار داخلي اختياري عند الضغط على البانر
  final int order;
  final bool isActive;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.linkTarget,
    this.order = 0,
    this.isActive = true,
  });

  factory BannerModel.fromMap(String id, Map<String, dynamic> map) {
    return BannerModel(
      id: id,
      imageUrl: (map['imageUrl'] ?? '') as String,
      title: map['title'] as String?,
      linkTarget: map['linkTarget'] as String?,
      order: (map['order'] ?? 0) as int,
      isActive: (map['isActive'] ?? true) as bool,
    );
  }

  factory BannerModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return BannerModel.fromMap(doc.id, doc.data() ?? {});
  }
}
