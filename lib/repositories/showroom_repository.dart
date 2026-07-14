import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/showroom_model.dart';
import '../services/firebase_service.dart';

/// طبقة الوصول إلى بيانات Showrooms من Firestore. مصدر واحد يُستخدم في
/// قسم NOS SHOWROOMS بالصفحة الرئيسية، صفحة "Nos Showrooms" الكاملة، وصفحة
/// تفاصيل Showroom واحد.
abstract class ShowroomRepository {
  /// قائمة محدودة (Home section).
  Future<List<ShowroomModel>> getShowrooms({int limit = 10});

  /// كل الـ Showrooms الفعّالة (active == true)، مرتّبة حسب displayOrder،
  /// لصفحة "Nos Showrooms" الكاملة.
  Future<List<ShowroomModel>> getAllActiveShowrooms();

  /// Showroom واحد عبر معرّفه الحقيقي (لصفحة تفاصيل Showroom).
  Future<ShowroomModel?> getShowroomById(String showroomId);
}

class FirebaseShowroomRepository implements ShowroomRepository {
  final FirebaseFirestore _db = FirebaseService.instance.firestore;

  @override
  Future<List<ShowroomModel>> getShowrooms({int limit = 10}) async {
    final snapshot = await _db
        .collection(AppConfig.collectionShowrooms)
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map(ShowroomModel.fromDoc).toList();
  }

  @override
  Future<List<ShowroomModel>> getAllActiveShowrooms() async {
    final snapshot = await _db
        .collection(AppConfig.collectionShowrooms)
        .where('active', isEqualTo: true)
        .orderBy('displayOrder')
        .get();

    return snapshot.docs.map(ShowroomModel.fromDoc).toList();
  }

  @override
  Future<ShowroomModel?> getShowroomById(String showroomId) async {
    final doc = await _db.collection(AppConfig.collectionShowrooms).doc(showroomId).get();
    if (!doc.exists) return null;
    return ShowroomModel.fromDoc(doc);
  }
}
