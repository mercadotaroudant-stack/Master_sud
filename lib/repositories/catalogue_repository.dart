import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/catalogue_model.dart';
import '../services/firebase_service.dart';

/// طبقة الوصول إلى بيانات الكتالوجات (catalogues) من Firestore.
/// تُستخدم خصوصًا لربط منتج معيّن بالكتالوج الذي اختاره المسؤول له من
/// لوحة التحكم (product.catalogueId) — بدون أي كتالوج ثابت أو افتراضي.
abstract class CatalogueRepository {
  Future<CatalogueModel?> getCatalogueById(String catalogueId);
}

class FirebaseCatalogueRepository implements CatalogueRepository {
  final FirebaseFirestore _db = FirebaseService.instance.firestore;

  @override
  Future<CatalogueModel?> getCatalogueById(String catalogueId) async {
    if (catalogueId.isEmpty) return null;
    final doc = await _db.collection(AppConfig.collectionCatalogues).doc(catalogueId).get();
    if (!doc.exists) return null;
    return CatalogueModel.fromDoc(doc);
  }
}
