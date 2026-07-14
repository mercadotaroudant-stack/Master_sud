import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/pro_request_model.dart';
import '../services/firebase_service.dart';

/// طبقة الوصول إلى بيانات "فضاء المحترفين" (Espace Pro) من Firestore.
/// الفريق يوافق/يرفض الطلب من لوحة التحكم — التطبيق فقط يرسل الطلب ويتتبّع
/// حالته لحظيًا عبر Firestore.
abstract class ProSpaceRepository {
  Future<String> submitRequest({
    required String name,
    required String company,
    required String phone,
    required String city,
  });

  Stream<ProRequestModel?> streamRequestStatus(String requestId);
}

class FirebaseProSpaceRepository implements ProSpaceRepository {
  final FirebaseFirestore _db = FirebaseService.instance.firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection(AppConfig.collectionProRequests);

  @override
  Future<String> submitRequest({
    required String name,
    required String company,
    required String phone,
    required String city,
  }) async {
    final doc = await _requests.add({
      'name': name,
      'company': company,
      'phone': phone,
      'city': city,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  @override
  Stream<ProRequestModel?> streamRequestStatus(String requestId) {
    return _requests.doc(requestId).snapshots().map(
          (doc) => doc.exists ? ProRequestModel.fromDoc(doc) : null,
        );
  }
}
