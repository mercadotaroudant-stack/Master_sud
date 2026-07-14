/// نموذج متغيّر منتج واحد (Taille / Variante) مثل "5kg", "10kg", "20kg".
/// كل القيم (السعر، سعر العرض، التوفر، المرجع) تأتي بالكامل من لوحة
/// التحكم عبر Firestore — لا يوجد أي قيمة افتراضية أو وهمية هنا.
///
/// Firestore (subfield of product doc): variants: [
///   {id, label, price, promoPrice, inStock, reference}
/// ]
class ProductVariant {
  final String id;
  final String label; // مثال: "10kg"
  final double price;
  final double? promoPrice; // null = لا يوجد عرض على هذا المتغيّر
  final bool inStock;
  final String? reference; // مرجع خاص بهذا المتغيّر إن وُجد

  const ProductVariant({
    required this.id,
    required this.label,
    required this.price,
    this.promoPrice,
    this.inStock = true,
    this.reference,
  });

  /// هل يوجد عرض ترويجي صالح فعليًا على هذا المتغيّر (سعر عرض أقل من السعر الأصلي)
  bool get hasValidPromo => promoPrice != null && promoPrice! > 0 && promoPrice! < price;

  /// السعر النهائي المعروض (سعر العرض إن وُجد، وإلا السعر العادي)
  double get effectivePrice => hasValidPromo ? promoPrice! : price;

  /// نسبة الخصم الحقيقية المحسوبة من بيانات Firebase فقط (وليست مُختلقة)
  int? get discountPercent {
    if (!hasValidPromo || price <= 0) return null;
    final percent = ((price - promoPrice!) / price) * 100;
    return percent.round();
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    final rawPromo = map['promoPrice'];
    return ProductVariant(
      id: (map['id'] ?? '') as String,
      label: (map['label'] ?? '') as String,
      price: ((map['price'] ?? 0) as num).toDouble(),
      promoPrice: rawPromo == null ? null : (rawPromo as num).toDouble(),
      inStock: (map['inStock'] ?? true) as bool,
      reference: map['reference'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'price': price,
        'promoPrice': promoPrice,
        'inStock': inStock,
        'reference': reference,
      };
}
