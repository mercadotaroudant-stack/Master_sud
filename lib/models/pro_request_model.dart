import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج طلب انضمام إلى "فضاء المحترفين" (Espace Pro).
///
/// Firestore collection: proRequests
/// الحقول: name, company, phone, city, status ('pending' | 'approved' |
/// 'rejected'), createdAt.
///
/// لا يوجد نظام حسابات/تسجيل دخول بعد في التطبيق، لذلك يُحفظ فقط معرّف
/// الطلب محليًا على الجهاز (SharedPreferences) بعد الإرسال، ليتم تتبّع حالة
/// نفس الطلب لاحقًا (قيد المراجعة / مقبول / مرفوض) بمجرد أن يعالجه الفريق
/// من لوحة التحكم.
class ProRequestModel {
  final String id;
  final String name;
  final String company;
  final String phone;
  final String city;
  final String status;
  final DateTime? createdAt;

  const ProRequestModel({
    required this.id,
    required this.name,
    required this.company,
    required this.phone,
    required this.city,
    required this.status,
    this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory ProRequestModel.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['createdAt'];
    return ProRequestModel(
      id: id,
      name: (map['name'] ?? '') as String,
      company: (map['company'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      city: (map['city'] ?? '') as String,
      status: (map['status'] ?? 'pending') as String,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  factory ProRequestModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ProRequestModel.fromMap(doc.id, doc.data() ?? {});
  }
}
