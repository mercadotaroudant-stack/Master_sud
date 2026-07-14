# Master Sud — Flutter App

مشروع Flutter احترافي لتطبيق **Master Sud** (دهانات وتكسيات)، مبني وفق Clean Architecture،
يشمل حاليًا: 3 شاشات Splash + الصفحة الرئيسية (Home)، مع تهيئة كاملة لـ Firebase وباقي الصفحات
كـ Placeholder بانتظار المرحلة القادمة.

## 📁 هيكلة المشروع

```
lib/
├── core/            # عناصر مشتركة (Result wrapper, ...)
├── config/          # إعدادات عامة، Firebase config، Routes
├── constants/       # ألوان، أبعاد، أصول (روابط الصور)، مفاتيح الترجمة
├── theme/           # ThemeData (Light جاهز، Dark محضّر للمستقبل)
├── localization/    # نظام ترجمة عربي/فرنسي بدون Code Generation
├── models/          # نماذج البيانات (Banner, Category, Product, Catalogue)
├── repositories/    # طبقة الوصول لبيانات Firestore
├── services/        # تهيئة Firebase (Auth, Firestore, Storage, Messaging, Analytics)
├── providers/       # إدارة الحالة عبر Provider (Locale, Home)
├── widgets/         # عناصر واجهة قابلة لإعادة الاستخدام
├── screens/
│   ├── splash/      # Splash 1 / 2 / 3
│   ├── home/        # الصفحة الرئيسية
│   └── placeholder/ # شاشة Placeholder عامة لباقي الصفحات
├── firebase/        # firebase_options.dart
└── main.dart
```

## ⚠️ خطوة ضرورية قبل التشغيل

هذا المجلد يحتوي على **كود Dart فقط** (مجلد `lib/` + `pubspec.yaml`). لم يتم توليد
مجلدات المنصّات (`android/`, `ios/`, `web/`...) تلقائيًا لأن ذلك يتطلب أداة
Flutter CLI الفعلية (غير متوفرة في هذه البيئة). اتبع الخطوات التالية على جهازك:

### 1. إنشاء هيكل المشروع الكامل

```bash
flutter create --org com.mastersud --project-name master_sud master_sud_full
```

### 2. نسخ الملفات

انسخ محتوى مجلد `lib/` بالكامل (استبدل الموجود)، وملف `pubspec.yaml`،
و`analysis_options.yaml` من هذا الأرشيف إلى داخل `master_sud_full/` الذي أنشأته للتو.

### 3. تثبيت الحزم

```bash
cd master_sud_full
flutter pub get
```

### 4. ربط Firebase بشكل صحيح (Android/iOS)

القيم الحالية في `lib/config/firebase_config.dart` و`lib/firebase/firebase_options.dart`
مأخوذة من إعدادات تطبيق **الويب** في Firebase. للحصول على `appId` صحيح لكل من
Android وiOS (وتوليد `google-services.json` و`GoogleService-Info.plist` تلقائيًا)، شغّل:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=sud-master
```

هذا سيحدّث `lib/firebase/firebase_options.dart` تلقائيًا بالقيم الصحيحة.

### 5. تشغيل التطبيق

```bash
flutter run
```

## 🔥 مجموعات Firestore المتوقعة حاليًا

| Collection   | الوصف                                  |
|--------------|------------------------------------------|
| `banners`    | صور البانر في الصفحة الرئيسية (`imageUrl`, `order`, `isActive`) |
| `categories` | قسم CATÉGORIES — الحقول: `id`, `title`, `titleAr`, `titleFr`, `image`, `color` (Hex مثل `#F5E6D3`), `order`, `active`, `createdAt`. يُعرض فقط `active = true`، مرتّبة حسب `order`. لون كل بطاقة يأتي بالكامل من الحقل `color` (لا يوجد لون ثابت داخل الكود). |
| `products`   | صفحة منتجات الفئة + PRODUITS POPULAIRES — الحقول: `id`, `nameAr`, `nameFr`, `descriptionAr`, `descriptionFr`, `imageUrl`, `price`, `weight`, `categoryId`, `isPromo`, `isPopular`, `isActive`, `createdAt`. |
| `showrooms`  | قسم NOS SHOWROOMS — الحقول: `id`, `city`, `address`, `phone`, `latitude`, `longitude`, `image`, `openingHours`, `active`, `createdAt`. |
| `videos`     | قسم VIDÉOS DE FORMATION (Home + صفحة Formation الكاملة) — الحقول: `id`, `title`, `description`, `thumbnail`/`thumbnailUrl`, `videoUrl`, `duration`, `category`, `active`/`isActive`, `order` (اختياري، يُستخدم لترتيب صفحة Formation), `createdAt`, `updatedAt`. |
| `stories`    | شريط الستوريات الدائم أسفل Banner Slider — كل مستند = شريحة واحدة (صورة أو فيديو). الحقول: `groupId` (يجمع عدّة شرائح فـ فقاعة واحدة), `groupTitle`, `groupCoverImage`, `groupOrder`, `mediaUrl`, `mediaType` (`image`/`video`), `itemOrder`, `isActive`/`active`, `createdAt`. لا حذف تلقائي بعد 24 ساعة. |
| `proRequests` | طلبات الانضمام إلى "Espace Pro" — الحقول: `name`, `company`, `phone`, `city`, `status` (`pending`/`approved`/`rejected`), `createdAt`. تُدار يدويًا من لوحة التحكم (لا يوجد بعد نظام حسابات/تسجيل دخول). |

سيتم إضافة باقي المجموعات (`catalogues`, `app_info`...) تباعًا
مع بناء كل صفحة في المراحل القادمة.

## 🔑 Firestore Composite Indexes مطلوبة

بسبب استخدام `where` مركّب مع `orderBy` على حقل مختلف، سيطلب Firestore إنشاء
Composite Index لكل من الاستعلامين التاليين (أول تشغيل سيُظهر رابطًا جاهزًا
في الـ Console لإنشائه تلقائيًا بضغطة واحدة، أو أنشئه يدويًا):

1. **`products`** — `isActive` (Ascending) + `isPopular` (Ascending) + `createdAt` (Descending)
   — لقسم PRODUITS POPULAIRES في Home.
2. **`products`** — `isActive` (Ascending) + `categoryId` (Ascending) + `createdAt` (Descending)
   — لصفحة منتجات الفئة (Category Products).

باقي الاستعلامات (`banners`, `categories`, `showrooms`, `videos`) تستخدم حقل
`where` واحد + `orderBy` على نفس الحقل، فلا تحتاج Composite Index.

## 🌐 اللغات

- العربية (RTL) — افتراضية
- الفرنسية (LTR)

يتم اختيار اللغة في Splash 3 وحفظها في `SharedPreferences`، فلا يُطلب من المستخدم
اختيارها مرة أخرى بعد أول استخدام.

## 🧩 الصفحات الحالية

- ✅ Splash 1 / 2 / 3
- ✅ Home (Header, Search Bar, القائمة الأفقية, Banner Slider, Categories, Produits Populaires, Nos Showrooms, Vidéos de Formation)
- ✅ Formation (`lib/screens/formation/`) — grille 2 colonnes des vidéos (temps réel via Firestore `snapshots()`), lecteur plein écran dédié
  (`lib/screens/formation/player/`) avec rotation automatique en paysage, contrôles custom (lecture/pause, ±10s, barre de
  progression, mute, Replay) et retour automatique en portrait à la fermeture.
- ✅ Calculateur de peinture (`lib/screens/calculator/`) — estimation 100% locale (aucune donnée Firebase) de la surface
  et du nombre de litres/pots nécessaires à partir des dimensions de la pièce. Accessible depuis le menu horizontal et
  le tiroir de navigation de la page d'accueil.
- ✅ Espace Pro (`lib/screens/pro_space/`) — demande d'adhésion professionnelle (`proRequests` sur Firestore) avec
  suivi de statut en temps réel (en attente / validé / refusé). Aucun système de comptes/authentification n'existe
  encore dans l'app : l'identifiant de la demande est simplement conservé sur l'appareil (SharedPreferences) pour
  retrouver son statut. **Étape manuelle requise côté Dashboard** : ajouter une vue listant les documents de
  `proRequests` et permettant de passer leur champ `status` à `approved`/`rejected`.
- ✅ Stories permanentes façon Instagram (`lib/widgets/stories_bar.dart` + `lib/screens/stories/story_viewer_screen.dart`) —
  bandeau de bulles juste sous le Banner Slider, alimenté en temps réel depuis Firestore (`stories`). Contrairement aux
  stories Instagram classiques, **elles ne sont jamais supprimées automatiquement après 24h** : elles restent visibles
  jusqu'à suppression/désactivation manuelle depuis le Dashboard. Le mode plein écran reproduit fidèlement Instagram :
  barres de progression segmentées, tap gauche/droite pour naviguer, appui long pour mettre en pause, swipe vers le bas
  pour fermer, swipe horizontal pour changer de bulle, anneau doré tant que non vue puis gris une fois vue (mémorisé
  localement sur l'appareil).
- ✅ Notifications de promotions (`lib/services/notification_service.dart`) — le téléphone s'abonne automatiquement au
  topic FCM `promos` ; toute notification envoyée à ce topic (Console Firebase ou Admin SDK) s'affiche au premier plan
  comme en arrière-plan. **Étapes manuelles requises** une fois les dossiers `android/` et `ios/` générés (`flutter
  create .`) : ajouter `google-services.json` / `GoogleService-Info.plist`, et sur Android 13+ déclarer la permission
  `POST_NOTIFICATIONS` dans `AndroidManifest.xml` (le plugin `flutter_local_notifications` la demande également au
  runtime via Firebase Messaging).
- 🚧 Produits, Catalogue, Showrooms, Papier peint, Devis, Commande
  (شاشات Placeholder مؤقتًا، سيتم بناؤها وربطها بـ Firebase خطوة بخطوة لاحقًا)
