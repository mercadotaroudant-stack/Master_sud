/// إعدادات Firebase الخام لمشروع Master Sud.
/// ملاحظة: هذه القيم مأخوذة من إعدادات تطبيق الويب (Web App) في Firebase Console.
/// لتشغيل التطبيق على Android/iOS بشكل صحيح، يفضّل توليد ملف
/// lib/firebase/firebase_options.dart تلقائيًا عبر أداة FlutterFire:
///   flutterfire configure
/// وهذا سيولّد appId مخصص لكل منصة (Android/iOS/Web) بدلاً من الاعتماد على قيمة الويب فقط.
class FirebaseConfig {
  FirebaseConfig._();

  static const String apiKey = 'AIzaSyAVjKL-YD0WNci28D1jZnoEowdsvJsyGBQ';
  static const String authDomain = 'sud-master.firebaseapp.com';
  static const String databaseURL = 'https://sud-master-default-rtdb.firebaseio.com';
  static const String projectId = 'sud-master';
  static const String storageBucket = 'sud-master.firebasestorage.app';
  static const String messagingSenderId = '1025305355014';
  static const String appId = '1:1025305355014:web:2f5889d7ace7bb6719f487';
  static const String measurementId = 'G-KBTJP6Y56Q';
}
