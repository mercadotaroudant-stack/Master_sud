import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/banner_model.dart';
import '../services/firebase_service.dart';

/// طبقة الوصول إلى بيانات الـ Banners من Firestore.
/// فصل الوصول للبيانات عن الـ UI/Provider يسهّل الاستبدال أو الاختبار لاحقًا.
abstract class BannerRepository {
  Future<List<BannerModel>> getActiveBanners();
}

class FirebaseBannerRepository implements BannerRepository {
  final FirebaseFirestore _db = FirebaseService.instance.firestore;

  @override
  Future<List<BannerModel>> getActiveBanners() async {
    final snapshot = await _db
        .collection(AppConfig.collectionBanners)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    return snapshot.docs.map(BannerModel.fromDoc).toList();
  }
}
