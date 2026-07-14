/// عنصر واحد ضمن قسم "Caractéristiques" في صفحة تفاصيل المنتج.
/// كل عنصر (label/value) يُضاف ديناميكيًا من لوحة التحكم (Dashboard) ولا
/// يوجد أي حقل ثابت (Type, Finition, Rendement...) داخل التطبيق نفسه —
/// هذه كانت فقط أمثلة بصرية في المواصفات، وليست بنية إلزامية.
///
/// Firestore (subfield of product doc): characteristics: [{label, value}]
class ProductCharacteristic {
  final String label;
  final String value;

  const ProductCharacteristic({required this.label, required this.value});

  factory ProductCharacteristic.fromMap(Map<String, dynamic> map) {
    return ProductCharacteristic(
      label: (map['label'] ?? '') as String,
      value: (map['value'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {'label': label, 'value': value};
}
