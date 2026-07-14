/// عنصر واحد داخل سلة التسوق (Panier). يُبنى فقط من بيانات منتج حقيقي
/// قادم من Firebase — لا يوجد أي إنشاء لعناصر سلة وهمية.
class CartItemModel {
  final String productId;
  final String productName;
  final String? selectedVariantId;
  final String? selectedVariantLabel;
  final double unitPrice;
  final int quantity;
  final String imageUrl;

  const CartItemModel({
    required this.productId,
    required this.productName,
    this.selectedVariantId,
    this.selectedVariantLabel,
    required this.unitPrice,
    required this.quantity,
    required this.imageUrl,
  });

  /// مفتاح فريد لتجميع نفس المنتج + نفس المتغيّر داخل السلة.
  String get lineKey => '$productId::${selectedVariantId ?? ''}';

  double get totalPrice => unitPrice * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      productId: productId,
      productName: productName,
      selectedVariantId: selectedVariantId,
      selectedVariantLabel: selectedVariantLabel,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
    );
  }
}
