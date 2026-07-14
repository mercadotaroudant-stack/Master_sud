import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/app_config.dart';
import '../firebase/firebase_options.dart';

/// Gère l'affichage des notifications de promotions/offres.
///
/// Le Dashboard/l'équipe marketing envoie les notifications au topic FCM
/// `promos` (via la Console Firebase ou l'Admin SDK) ; ce service se charge
/// uniquement de les afficher sur l'appareil (au premier plan comme en
/// arrière-plan) — aucune promotion n'est générée ou codée en dur ici.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'promos_channel';
  static const _channelName = 'Promotions';
  static const _channelDescription = 'Offres et promotions Master Sud';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // demandée explicitement ci-dessous via FirebaseMessaging
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _localNotifications.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.subscribeToTopic(AppConfig.fcmPromosTopic);

      FirebaseMessaging.onMessage.listen(_showForegroundNotification);

      _initialized = true;
    } catch (e) {
      // في حال فشل التهيئة (مثلاً منصّة Android/iOS غير مُعدّة بعد) نُكمل
      // تشغيل التطبيق بدون إشعارات بدل الانهيار الكامل.
      // ignore: avoid_print
      print('NotificationService init error: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}

/// Handler des messages FCM reçus alors que l'application est en arrière-plan
/// ou terminée. Doit être une fonction top-level (hors classe) et annotée
/// `@pragma('vm:entry-point')` pour rester accessible depuis l'isolate natif.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Cet handler peut s'exécuter dans un isolate séparé qui n'a pas Firebase
  // déjà initialisé : on s'en assure ici avant tout traitement, sans jamais
  // réinitialiser une instance déjà existante.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  // Le système affiche déjà automatiquement les notifications FCM classiques
  // reçues en arrière-plan sur Android/iOS ; ce handler reste disponible pour
  // un traitement additionnel (ex. mise à jour de données locales) si besoin
  // plus tard, sans dupliquer l'affichage.
  if (kDebugMode) {
    print('Background promo message received: ${message.messageId}');
  }
}
