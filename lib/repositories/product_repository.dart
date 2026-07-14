import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/product_model.dart';
import '../services/firebase_service.dart';

/// طبقة الوصول إلى بيانات المنتجات من Firestore. مصدر واحد يُستخدم في
/// Produits Populaires، صفحة منتجات الفئة، والبحث مستقبلاً.
abstract class ProductRepository {
  /// المنتجات الشائعة (isPopular == true) لقسم PRODUITS POPULAIRES في Home.
  Future<List<ProductModel>> getPopularProducts({int limit = 10});

  /// كل المنتجات الفعّالة (isActive == true) التابعة لفئة معيّنة (categoryId).
  Future<List<ProductModel>> getProductsByCategory(String categoryId);

  /// منتج واحد عبر معرّفه الحقيقي في Firestore (لصفحة تفاصيل المنتج).
  Future<ProductModel?> getProductById(String productId);
}

class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _db = FirebaseService.instance.firestore;

  @override
  Future<List<ProductModel>> getPopularProducts({int limit = 10}) async {
    final snapshot = await _db
        .collection(AppConfig.collectionProducts)
        .where('isActive', isEqualTo: true)
        .where('isPopular', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map(ProductModel.fromDoc).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final snapshot = await _db
        .collection(AppConfig.collectionProducts)
        .where('isActive', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map(ProductModel.fromDoc).toList();
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _db.collection(AppConfig.collectionProducts).doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromDoc(doc);
  }
}
