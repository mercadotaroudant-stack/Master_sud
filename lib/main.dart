import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_config.dart';
import 'config/routes.dart';
import 'localization/app_localizations.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_flow.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تثبيت اتجاه الشاشة (اختياري، يمكن حذفه لدعم Landscape مستقبلاً)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة Firebase قبل تشغيل التطبيق حتى تكون كل الخدمات جاهزة من البداية
  await FirebaseService.instance.init();

  // تسجيل معالج الإشعارات في الخلفية قبل تشغيل التطبيق (شرط ضروري لـ FCM)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.instance.init();

  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  runApp(MasterSudApp(localeProvider: localeProvider));
}

class MasterSudApp extends StatelessWidget {
  final LocaleProvider localeProvider;

  const MasterSudApp({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<FavoritesProvider>(create: (_) => FavoritesProvider()..load()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, locale, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConfig.appName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light, // سيتم تفعيل التبديل التلقائي مستقبلاً
            locale: locale.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routes: AppRoutes.routes,
            home: const AppEntryPoint(),
          );
        },
      ),
    );
  }
}

/// يقرر عرض تدفق الـ Splash (أول تشغيل فقط) أو الانتقال مباشرة إلى Home.
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool? _hasSeenSplash;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(AppConfig.prefHasSeenSplash) ?? false;
    if (!mounted) return;
    setState(() => _hasSeenSplash = seen);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenSplash == null) {
      return const Scaffold(backgroundColor: Colors.white, body: SizedBox.shrink());
    }
    return _hasSeenSplash! ? const HomeScreen() : const SplashFlow();
  }
}
