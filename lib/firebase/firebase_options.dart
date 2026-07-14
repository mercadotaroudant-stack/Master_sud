import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import '../config/firebase_config.dart';

/// خيارات Firebase الافتراضية لكل منصة.
///
/// ⚠️ ملاحظة مهمة:
/// القيم أدناه مبنية على إعدادات تطبيق الـ Web من Firebase Console التي
/// زوّدتنا بها. هذا يكفي لتشغيل التطبيق على الويب مباشرة.
/// لتشغيله على Android و iOS بأفضل شكل (مع ملفات google-services.json و
/// GoogleService-Info.plist الصحيحة)، يُفضّل تشغيل الأمر التالي مرة واحدة
/// من جذر المشروع بعد تثبيت FlutterFire CLI:
///
///   dart pub global activate flutterfire_cli
///   flutterfire configure
///
/// سيقوم هذا الأمر تلقائيًا بتوليد نسخة محدّثة من هذا الملف مع appId مخصص
/// لكل منصة، وبإضافة ملفات الإعداد المطلوبة داخل android/ و ios/.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: FirebaseConfig.apiKey,
    authDomain: FirebaseConfig.authDomain,
    databaseURL: FirebaseConfig.databaseURL,
    projectId: FirebaseConfig.projectId,
    storageBucket: FirebaseConfig.storageBucket,
    messagingSenderId: FirebaseConfig.messagingSenderId,
    appId: FirebaseConfig.appId,
    measurementId: FirebaseConfig.measurementId,
  );

  /// يُستحسن استبدال هذا بالقيم الحقيقية بعد `flutterfire configure`
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: FirebaseConfig.apiKey,
    projectId: FirebaseConfig.projectId,
    storageBucket: FirebaseConfig.storageBucket,
    messagingSenderId: FirebaseConfig.messagingSenderId,
    appId: FirebaseConfig.appId,
    databaseURL: FirebaseConfig.databaseURL,
  );

  /// يُستحسن استبدال هذا بالقيم الحقيقية بعد `flutterfire configure`
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: FirebaseConfig.apiKey,
    projectId: FirebaseConfig.projectId,
    storageBucket: FirebaseConfig.storageBucket,
    messagingSenderId: FirebaseConfig.messagingSenderId,
    appId: FirebaseConfig.appId,
    databaseURL: FirebaseConfig.databaseURL,
  );
}
