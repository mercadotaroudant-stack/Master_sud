import 'package:flutter/material.dart';

/// نظام ترجمة بسيط (بدون Code Generation) يدعم العربية والفرنسية فقط
/// كما هو مطلوب في هذه المرحلة. لإضافة لغة جديدة مستقبلاً يكفي إضافة
/// Map جديدة داخل [_localizedValues].
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const supportedLocales = [Locale('ar'), Locale('fr')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_name': 'ماستر سود',
      'tagline': 'دهانات وتكسيات',
      'search': 'ابحث عن منتج، لون، كتالوج...',
      'devis': 'عرض سعر',
      'commande': 'طلبية',
      'menu_peinture': 'دهان',
      'menu_produits': 'المنتجات',
      'menu_catalogue': 'الكتالوج',
      'menu_showrooms': 'صالات العرض',
      'menu_papier_peint': 'ورق الجدران',
      'menu_formation': 'التكوين',
      'menu_calculator': 'حاسبة الصباغة',
      'menu_pro_space': 'فضاء المحترفين',
      'categories_title': 'الفئات',
      'see_all': 'عرض الكل',
      'no_categories': 'لا توجد فئات متاحة',
      'popular_products': 'المنتجات الشائعة',
      'our_showrooms': 'صالات العرض لدينا',
      'training_videos': 'فيديوهات التكوين',
      'view_details': 'عرض التفاصيل',
      'promo_label': 'عرض',
      'no_products': 'لا توجد منتجات متاحة',
      'no_showrooms': 'لا توجد صالات عرض متاحة',
      'no_videos': 'لا توجد فيديوهات متاحة',
      'product_details': 'تفاصيل المنتج',
      'breadcrumb_home': 'الرئيسية',
      'all_products': 'كل المنتجات',
      'product_not_found': 'هذا المنتج غير متاح حاليًا',
      'coming_soon': 'قريبًا',
      'coming_soon_desc': 'هذه الصفحة قيد التطوير وستكون متاحة قريبًا.',
      'back_home': 'العودة للرئيسية',
      'error_load': 'تعذر تحميل البيانات',
      'retry': 'إعادة المحاولة',
      'no_data': 'لا توجد بيانات حاليًا',
      'start': 'ابدأ الآن',
    },
    'fr': {
      'app_name': 'Master Sud',
      'tagline': 'Peintures & Revêtements',
      'search': 'Rechercher un produit, une couleur...',
      'devis': 'Devis',
      'commande': 'Commande',
      'menu_peinture': 'Peinture',
      'menu_produits': 'Produits',
      'menu_catalogue': 'Catalogue',
      'menu_showrooms': 'Showrooms',
      'menu_papier_peint': 'Papier peint',
      'menu_formation': 'Formation',
      'menu_calculator': 'Calculateur',
      'menu_pro_space': 'Espace Pro',
      'categories_title': 'Catégories',
      'see_all': 'Voir tout',
      'no_categories': 'Aucune catégorie disponible',
      'popular_products': 'Produits populaires',
      'our_showrooms': 'Nos showrooms',
      'training_videos': 'Vidéos de formation',
      'view_details': 'Voir détails',
      'promo_label': 'PROMO',
      'no_products': 'Aucun produit disponible',
      'no_showrooms': 'Aucun showroom disponible',
      'no_videos': 'Aucune vidéo disponible',
      'product_details': 'Détails du produit',
      'breadcrumb_home': 'Accueil',
      'all_products': 'Tous les produits',
      'product_not_found': "Ce produit n'est plus disponible",
      'coming_soon': 'Bientôt disponible',
      'coming_soon_desc': 'Cette page est en cours de développement.',
      'back_home': "Retour à l'accueil",
      'error_load': 'Impossible de charger les données',
      'retry': 'Réessayer',
      'no_data': 'Aucune donnée pour le moment',
      'start': 'Commencer',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  bool get isArabic => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// اختصار مريح: context.tr('key')
extension LocalizationExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this).t(key);
}
