/// إعدادات عامة للتطبيق (Environment / Feature flags بسيطة).
class AppConfig {
  AppConfig._();

  static const String appName = 'Master Sud';
  static const String tagline = 'Peintures & Revêtements';

  /// مفاتيح SharedPreferences
  static const String prefHasSeenSplash = 'has_seen_splash';
  static const String prefLanguageCode = 'app_language';

  /// مسارات Firestore الأساسية (سيتم استخدامها تباعًا في المراحل القادمة)
  static const String collectionBanners = 'banners';
  static const String collectionCategories = 'categories';
  static const String collectionProducts = 'products';
  static const String collectionCatalogues = 'catalogues';

  /// Collection dédiée à la section CATALOGUE (catalogues de peinture +
  /// leurs couleurs, gérés entièrement depuis le Dashboard).
  /// Volontairement distincte de `collectionCatalogues` ci-dessus, qui reste
  /// utilisée par la fiche produit (product.catalogueId -> PDF du catalogue)
  /// et ne doit pas être modifiée.
  static const String collectionPaintCatalogues = 'paintCatalogues';
  static const String subcollectionCatalogueColors = 'colors';
  static const String collectionVideos = 'videos';
  static const String collectionShowrooms = 'showrooms';
  static const String collectionAppInfo = 'app_info';

  /// Espace Pro — demandes d'adhésion (validées manuellement depuis le
  /// Dashboard). Chaque appareil garde l'identifiant de sa propre demande
  /// dans SharedPreferences (pas de système de comptes/authentification
  /// pour le moment).
  static const String collectionProRequests = 'proRequests';
  static const String prefProRequestId = 'pro_request_id';

  /// Topic FCM utilisé pour les notifications de promotions/offres.
  static const String fcmPromosTopic = 'promos';

  /// Bandeau de "stories" façon Instagram sous le Banner Slider — permanentes
  /// (pas de suppression automatique après 24h), gérées depuis le Dashboard.
  static const String collectionStories = 'stories';
  static const String prefSeenStoryGroups = 'seen_story_groups';
}
