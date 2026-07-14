import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// يدير لغة التطبيق الحالية (عربي/فرنسي) ويحفظ الاختيار في SharedPreferences
/// بحيث لا يُطلب من المستخدم اختيار اللغة مرة أخرى بعد Splash 3.
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConfig.prefLanguageCode);
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.prefLanguageCode, locale.languageCode);
  }
}
