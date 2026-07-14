import 'package:cloud_firestore/cloud_firestore.dart';

import 'product_characteristic_model.dart';
import 'product_variant_model.dart';

/// نموذج المنتج الموحّد المستخدم في كل مكان بالتطبيق (Categories, Produits
/// Populaires, صفحة المنتجات, نتائج البحث, صفحة تفاصيل المنتج...). مصدر واحد
/// للحقيقة لبيانات المنتج، كلها قادمة من Firestore دون أي بيانات ثابتة.
///
/// Firestore collection: products
/// الحقول الأساسية: id, nameAr, nameFr, descriptionAr, descriptionFr,
/// imageUrl, price, weight, categoryId, isPromo, isPopular, isActive,
/// createdAt.
///
/// الحقول الإضافية الخاصة بصفحة "Détails du produit" (كلها اختيارية ومُدارة
/// بالكامل من لوحة التحكم Dashboard):
/// reference, images (List<String>), variants (List<ProductVariant>),
/// isInterior, isExterior, characteristics (List<ProductCharacteristic>),
/// applicationImages (List<String>), catalogueId.
class ProductModel {
  final String id;
  final String nameAr;
  final String nameFr;
  final String descriptionAr;
  final String descriptionFr;
  final String imageUrl;
  final double price;
  final String weight; // مثال: "5kg"
  final String? categoryId;
  final bool isPromo;
  final bool isPopular;
  final bool isActive;
  final DateTime? createdAt;

  /// مرجع المنتج (SKU) — يُعرض فقط إن وُجد فعليًا في Firebase.
  final String? reference;

  /// صور المنتج المتعددة (Slider). إن كانت فارغة يتم استعمال [imageUrl]
  /// كصورة وحيدة احتياطيًا حتى لا تنكسر الشاشات التي تعرض صورة واحدة فقط.
  final List<String> images;

  /// متغيّرات المنتج (Taille/Variante) — أسعار، مخزون، ومرجع مستقلّة لكل
  /// متغيّر. يمكن أن تكون فارغة لمنتج بدون أحجام متعددة.
  final List<ProductVariant> variants;

  /// هل المنتج مخصّص للاستخدام الداخلي — يُضبط فقط من لوحة التحكم.
  final bool isInterior;

  /// هل المنتج مخصّص للاستخدام الخارجي — يُضبط فقط من لوحة التحكم.
  final bool isExterior;

  /// حالة توفر المخزون العامة للمنتج (تُستبدل بحالة المتغيّر المختار إن
  /// وُجدت متغيّرات).
  final bool inStock;

  /// سعر العرض الترويجي على مستوى المنتج (يُستخدم فقط عند عدم وجود
  /// متغيّرات، أو كقيمة احتياطية). null = لا يوجد عرض.
  final double? promoPrice;

  /// الخصائص التقنية الديناميكية (Caractéristiques) — key/value من Dashboard.
  final List<ProductCharacteristic> characteristics;

  /// صور أمثلة التطبيق (Exemples d'application) — من Dashboard فقط.
  final List<String> applicationImages;

  /// معرّف الكتالوج المرتبط بهذا المنتج تحديدًا (product.catalogueId).
  /// يُستخدم زر "Catalogue" لفتح الكتالوج الصحيح المرتبط بهذا المنتج فقط.
  final String? catalogueId;

  const ProductModel({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    this.descriptionAr = '',
    this.descriptionFr = '',
    required this.imageUrl,
    required this.price,
    this.weight = '',
    this.categoryId,
    this.isPromo = false,
    this.isPopular = false,
    this.isActive = true,
    this.createdAt,
    this.reference,
    this.images = const [],
    this.variants = const [],
    this.isInterior = false,
    this.isExterior = false,
    this.inStock = true,
    this.promoPrice,
    this.characteristics = const [],
    this.applicationImages = const [],
    this.catalogueId,
  });

  /// كل صور المنتج بشكل آمن: [images] إن وُجدت، وإلا [imageUrl] وحيدة،
  /// وإلا قائمة فارغة (سيتم عرض fallback بصري في الواجهة).
  List<String> get galleryImages {
    if (images.isNotEmpty) return images;
    if (imageUrl.isNotEmpty) return [imageUrl];
    return const [];
  }

  /// هل يملك المنتج متغيّرات حقيقية (Tailles) قادمة من Firebase.
  bool get hasVariants => variants.isNotEmpty;

  /// قائمة متغيّرات موحّدة للاستخدام في الواجهة: إن وُجدت [variants] حقيقية
  /// تُستعمل كما هي، وإلا يُبنى متغيّر افتراضي وحيد من الحقول العلوية للمنتج
  /// (price/promoPrice/weight/inStock/reference) حتى لا تُضطر الواجهة إلى
  /// معالجة حالتين مختلفتين. لا يوجد أي بيانات مُختلقة هنا — كلها من Firebase.
  List<ProductVariant> get effectiveVariants {
    if (variants.isNotEmpty) return variants;
    return [
      ProductVariant(
        id: '',
        label: weight,
        price: price,
        promoPrice: (isPromo && promoPrice != null && promoPrice! > 0) ? promoPrice : null,
        inStock: inStock,
        reference: reference,
      ),
    ];
  }

  String name(bool isArabic) {
    final localized = isArabic ? nameAr : nameFr;
    return localized.isNotEmpty ? localized : (nameFr.isNotEmpty ? nameFr : nameAr);
  }

  String description(bool isArabic) {
    final localized = isArabic ? descriptionAr : descriptionFr;
    return localized.isNotEmpty ? localized : (descriptionFr.isNotEmpty ? descriptionFr : descriptionAr);
  }

  /// السعر مُنسّق كـ "180 DH"
  String get formattedPrice => formatPrice(price);

  /// تنسيق أي قيمة سعر (متغيّر مثلاً) بنفس الصيغة "180 DH" / "179.90 DH"
  static String formatPrice(double value) {
    final isWhole = value.truncateToDouble() == value;
    return '${value.toStringAsFixed(isWhole ? 0 : 2)} DH';
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['createdAt'];

    final rawImages = map['images'];
    final images = rawImages is List
        ? rawImages.whereType<String>().where((e) => e.isNotEmpty).toList()
        : <String>[];

    final rawVariants = map['variants'];
    final variants = rawVariants is List
        ? rawVariants
            .whereType<Map>()
            .map((e) => ProductVariant.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <ProductVariant>[];

    final rawCharacteristics = map['characteristics'];
    final characteristics = rawCharacteristics is List
        ? rawCharacteristics
            .whereType<Map>()
            .map((e) => ProductCharacteristic.fromMap(Map<String, dynamic>.from(e)))
            .where((c) => c.label.isNotEmpty && c.value.isNotEmpty)
            .toList()
        : <ProductCharacteristic>[];

    final rawApplicationImages = map['applicationImages'];
    final applicationImages = rawApplicationImages is List
        ? rawApplicationImages.whereType<String>().where((e) => e.isNotEmpty).toList()
        : <String>[];

    return ProductModel(
      id: id,
      nameAr: (map['nameAr'] ?? '') as String,
      nameFr: (map['nameFr'] ?? '') as String,
      descriptionAr: (map['descriptionAr'] ?? '') as String,
      descriptionFr: (map['descriptionFr'] ?? '') as String,
      imageUrl: (map['imageUrl'] ?? '') as String,
      price: ((map['price'] ?? 0) as num).toDouble(),
      weight: (map['weight'] ?? '') as String,
      categoryId: map['categoryId'] as String?,
      isPromo: (map['isPromo'] ?? false) as bool,
      isPopular: (map['isPopular'] ?? false) as bool,
      isActive: (map['isActive'] ?? true) as bool,
      createdAt: ts is Timestamp ? ts.toDate() : null,
      reference: (map['reference'] as String?)?.trim().isNotEmpty == true ? map['reference'] as String : null,
      images: images,
      variants: variants,
      isInterior: (map['isInterior'] ?? false) as bool,
      isExterior: (map['isExterior'] ?? false) as bool,
      inStock: (map['inStock'] ?? true) as bool,
      promoPrice: map['promoPrice'] == null ? null : (map['promoPrice'] as num).toDouble(),
      characteristics: characteristics,
      applicationImages: applicationImages,
      catalogueId: (map['catalogueId'] as String?)?.trim().isNotEmpty == true ? map['catalogueId'] as String : null,
    );
  }

  factory ProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ProductModel.fromMap(doc.id, doc.data() ?? {});
  }
}
