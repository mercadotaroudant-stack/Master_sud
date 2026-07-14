import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// نموذج بيانات الفئة (Category) — قسم CATÉGORIES في الصفحة الرئيسية.
/// كل الحقول قادمة بالكامل من Firestore (لا يوجد أي بيانات ثابتة داخل التطبيق).
///
/// Firestore collection: categories
/// الحقول: id, title, titleAr, titleFr, image, color, order, active, createdAt
class CategoryModel {
  final String id;
  final String title; // عنوان افتراضي/عام (fallback)
  final String titleAr;
  final String titleFr;
  final String image;
  final String colorHex; // مثال: "#F5E6D3"
  final int order;
  final bool active;
  final DateTime? createdAt;
  final String? description; // وصف قصير اختياري

  const CategoryModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.titleFr,
    required this.image,
    required this.colorHex,
    this.order = 0,
    this.active = true,
    this.createdAt,
    this.description,
  });

  /// اسم الفئة بحسب اللغة الحالية، مع fallback إلى title العام إذا كانت
  /// الترجمة المحلية غير متوفرة.
  String name(bool isArabic) {
    final localized = isArabic ? titleAr : titleFr;
    return localized.isNotEmpty ? localized : title;
  }

  /// يحوّل قيمة اللون القادمة من Firebase (مثل "#F5E6D3" أو "F5E6D3") إلى [Color].
  /// في حال كانت القيمة غير صالحة أو مفقودة، يُستخدم لون رمادي فاتح كـ fallback آمن.
  Color get backgroundColor {
    final hex = colorHex.trim().replaceFirst('#', '');
    if (hex.length == 6 || hex.length == 8) {
      final value = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
      if (value != null) return Color(value);
    }
    return const Color(0xFFF2F2F2);
  }

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['createdAt'];
    return CategoryModel(
      id: id,
      title: (map['title'] ?? '') as String,
      titleAr: (map['titleAr'] ?? '') as String,
      titleFr: (map['titleFr'] ?? '') as String,
      image: (map['image'] ?? '') as String,
      colorHex: (map['color'] ?? '#F2F2F2') as String,
      order: (map['order'] ?? 0) as int,
      active: (map['active'] ?? true) as bool,
      createdAt: ts is Timestamp ? ts.toDate() : null,
      description: map['description'] as String?,
    );
  }

  factory CategoryModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CategoryModel.fromMap(doc.id, doc.data() ?? {});
  }
}
