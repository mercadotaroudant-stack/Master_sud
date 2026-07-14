import 'package:cloud_firestore/cloud_firestore.dart';

import 'showroom_day_schedule_model.dart';
import 'showroom_schedule_group.dart';
import 'showroom_service_model.dart';

/// نموذج Showroom — يُستخدم في قسم NOS SHOWROOMS بالصفحة الرئيسية، صفحة
/// "Nos Showrooms" الكاملة، وصفحة "Détails du showroom". كل الحقول قادمة من
/// Firestore دون أي بيانات ثابتة أو وهمية.
///
/// Firestore collection: showrooms
/// الحقول: id, name, city, badgeLabel, address, phone, latitude, longitude,
/// mapsUrl, image, openingHours (legacy text fallback), openingSchedule
/// (map<weekday, {open, close, closed}>), timezone, description,
/// galleryImages, services, active, displayOrder, createdAt.
class ShowroomModel {
  final String id;

  /// اسم الـ Showroom الظاهر (مثال: "MASTER SUD Casablanca"). إن كان فارغًا
  /// تُستعمل [city] كبديل آمن في الواجهة.
  final String name;

  final String city;
  final String address;
  final String? phone;
  final double? latitude;
  final double? longitude;

  /// رابط خرائط جاهز (اختياري) — يُستعمل إن لم تتوفر latitude/longitude.
  final String? mapsUrl;

  /// الصورة الرئيسية (Hero / بطاقة القائمة).
  final String image;

  /// نص ساعات عمل حر (احتياطي قديم) — يُستعمل فقط إن لم يوجد
  /// [openingSchedule] منظّم لليوم الحالي.
  final String? openingHours;

  /// جدول أوقات العمل لكل يوم من أيام الأسبوع (Dashboard-controlled).
  /// المفتاح: DateTime.weekday (1 = الاثنين ... 7 = الأحد).
  final Map<int, ShowroomDaySchedule> openingSchedule;

  /// المنطقة الزمنية للـ Showroom إن أراد المسؤول ضبطها (اختياري، معلوماتي
  /// حاليًا — المقارنة تعتمد على توقيت الجهاز المحلي).
  final String? timezone;

  /// نص الشارة أعلى يمين الصورة (مثال: "DÉPÔT CASABLANCA"). يأتي حرفيًا من
  /// Firebase. لا يُبنى تلقائيًا من المدينة. تُخفى الشارة إن كانت فارغة.
  final String? badgeLabel;

  /// وصف "À propos de notre showroom" — يُخفى القسم بالكامل إن كان فارغًا.
  final String description;

  /// صور معرض "Galerie" — بالكامل من لوحة التحكم. لا حد أقصى/أدنى مفترض.
  final List<String> galleryImages;

  /// خدمات "Services disponibles" الخاصة بهذا الـ Showroom تحديدًا.
  final List<ShowroomService> services;

  final bool active;
  final int displayOrder;
  final DateTime? createdAt;

  const ShowroomModel({
    required this.id,
    this.name = '',
    required this.city,
    required this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.mapsUrl,
    required this.image,
    this.openingHours,
    this.openingSchedule = const {},
    this.timezone,
    this.badgeLabel,
    this.description = '',
    this.galleryImages = const [],
    this.services = const [],
    this.active = true,
    this.displayOrder = 0,
    this.createdAt,
  });

  /// الاسم المعروض في الواجهة: [name] إن وُجد، وإلا [city].
  String get displayName => name.isNotEmpty ? name : city;

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;

  bool get hasLocation =>
      (latitude != null && longitude != null) || (mapsUrl != null && mapsUrl!.isNotEmpty) || address.isNotEmpty;

  bool get hasBadge => badgeLabel != null && badgeLabel!.trim().isNotEmpty;

  bool get hasDescription => description.trim().isNotEmpty;

  bool get hasGallery => galleryImages.isNotEmpty;

  /// خدمات فعّالة فقط، مرتّبة حسب displayOrder.
  List<ShowroomService> get activeServices {
    final list = services.where((s) => s.isActive && s.name.isNotEmpty).toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  ShowroomDaySchedule? get _todaySchedule => openingSchedule[DateTime.now().weekday];

  /// هل الـ Showroom مفتوح الآن — يُحسب فعليًا من جدول اليوم الحالي القادم
  /// من Firebase (ليس نصًا ثابتًا "Ouvert maintenant").
  bool get isOpenNow {
    final today = _todaySchedule;
    if (today == null) return false;
    return today.isOpenAt(DateTime.now());
  }

  /// نص ساعات اليوم الحالي "08:00 - 18:30"، أو الاحتياطي [openingHours]،
  /// أو null إن لم يتوفر أي منهما.
  String? get todayHoursLabel {
    final today = _todaySchedule;
    final structured = today?.label;
    if (structured != null) return structured;
    if (openingHours != null && openingHours!.trim().isNotEmpty) return openingHours;
    return null;
  }

  /// هل يوجد جدول أوقات مُعرّف أصلاً لهذا اليوم (لتمييز "لا بيانات" عن
  /// "مغلق فعليًا").
  bool get hasScheduleForToday => _todaySchedule != null || (openingHours != null && openingHours!.trim().isNotEmpty);

  /// جدول الأسبوع مُجمّعًا في نطاقات (لصفحة تفاصيل Showroom). فارغ إن لم
  /// يوجد أي جدول Firebase منظّم لهذا الـ Showroom.
  List<ShowroomScheduleGroup> get groupedSchedule => ShowroomScheduleGroup.build(openingSchedule);

  factory ShowroomModel.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['createdAt'];

    final rawSchedule = map['openingSchedule'];
    final schedule = <int, ShowroomDaySchedule>{};
    if (rawSchedule is Map) {
      rawSchedule.forEach((key, value) {
        final weekday = int.tryParse(key.toString());
        if (weekday != null && value is Map) {
          schedule[weekday] = ShowroomDaySchedule.fromMap(Map<String, dynamic>.from(value));
        }
      });
    }

    final rawGallery = map['galleryImages'];
    final gallery = rawGallery is List
        ? rawGallery.whereType<String>().where((e) => e.isNotEmpty).toList()
        : <String>[];

    final rawServices = map['services'];
    final services = rawServices is List
        ? rawServices
            .whereType<Map>()
            .map((e) => ShowroomService.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <ShowroomService>[];

    return ShowroomModel(
      id: id,
      name: (map['name'] ?? '') as String,
      city: (map['city'] ?? '') as String,
      address: (map['address'] ?? '') as String,
      phone: (map['phone'] as String?)?.trim().isNotEmpty == true ? map['phone'] as String : null,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      mapsUrl: (map['mapsUrl'] as String?)?.trim().isNotEmpty == true ? map['mapsUrl'] as String : null,
      image: (map['image'] ?? '') as String,
      openingHours: map['openingHours'] as String?,
      openingSchedule: schedule,
      timezone: map['timezone'] as String?,
      badgeLabel: (map['badgeLabel'] as String?)?.trim().isNotEmpty == true ? map['badgeLabel'] as String : null,
      description: (map['description'] ?? '') as String,
      galleryImages: gallery,
      services: services,
      active: (map['active'] ?? true) as bool,
      displayOrder: (map['displayOrder'] ?? 0) as int,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  factory ShowroomModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ShowroomModel.fromMap(doc.id, doc.data() ?? {});
  }
}
