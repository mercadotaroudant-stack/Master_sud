import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/category_model.dart';
import '../services/firebase_service.dart';

/// طبقة الوصول إلى بيانات الفئات (Categories) من Firestore.
/// يعرض فقط الفئات active = true، مرتّبة حسب order، بدون أي بيانات ثابتة.
abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();

  /// فئة واحدة عبر معرّفها الحقيقي — تُستخدم في breadcrumb صفحة تفاصيل
  /// المنتج لعرض اسم الفئة الفعلي (product.categoryId) بدل أي نص ثابت.
  Future<CategoryModel?> getCategoryById(String categoryId);
}

class FirebaseCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _db = FirebaseService.instance.firestore;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db
        .collection(AppConfig.collectionCategories)
        .where('active', isEqualTo: true)
        .orderBy('order')
        .get();

    return snapshot.docs.map(CategoryModel.fromDoc).toList();
  }

  @override
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    if (categoryId.isEmpty) return null;
    final doc = await _db.collection(AppConfig.collectionCategories).doc(categoryId).get();
    if (!doc.exists) return null;
    return CategoryModel.fromDoc(doc);
  }
}
