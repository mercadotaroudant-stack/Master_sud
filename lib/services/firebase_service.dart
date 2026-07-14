import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../firebase/firebase_options.dart';

/// نقطة مركزية واحدة للوصول إلى جميع خدمات Firebase (Auth, Firestore,
/// Storage, Messaging, Analytics). يتم تهيئتها مرة واحدة عند بدء التطبيق
/// عبر [FirebaseService.init].
class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  late final FirebaseFirestore firestore;
  late final FirebaseAuth auth;
  late final FirebaseStorage storage;
  FirebaseAnalytics? analytics;
  FirebaseMessaging? messaging;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firestore = FirebaseFirestore.instance;
      auth = FirebaseAuth.instance;
      storage = FirebaseStorage.instance;
      analytics = FirebaseAnalytics.instance;
      messaging = FirebaseMessaging.instance;

      // تفعيل الكاش الدائم (Offline Cache) لـ Firestore
      firestore.settings = const Settings(persistenceEnabled: true);

      await messaging?.requestPermission();
      _initialized = true;
    } catch (e) {
      // في حال فشل التهيئة (مثلاً ملفات google-services.json غير مضافة بعد)
      // نسمح للتطبيق بالاستمرار بدون Firebase مؤقتًا بدل الانهيار الكامل،
      // مع طباعة الخطأ لتسهيل التشخيص أثناء التطوير.
      // ignore: avoid_print
      print('Firebase init error: $e');
      _initialized = false;
    }
  }
}
