import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';

/// مزوّد حالة سلة التسوق (Panier). يخزّن فقط عناصر حقيقية أضافها المستخدم
/// انطلاقًا من منتجات Firebase الفعلية (لا بيانات وهمية إطلاقًا).
class CartProvider extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};

  List<CartItemModel> get items => _items.values.toList(growable: false);

  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// يضيف عنصرًا حقيقيًا للسلة. إن كان المنتج/المتغيّر نفسه موجودًا مسبقًا
  /// يتم فقط زيادة الكمية بدلاً من تكرار السطر.
  void addItem(CartItemModel item) {
    final key = item.lineKey;
    final existing = _items[key];
    if (existing != null) {
      _items[key] = existing.copyWith(quantity: existing.quantity + item.quantity);
    } else {
      _items[key] = item;
    }
    notifyListeners();
  }

  void removeItem(String lineKey) {
    _items.remove(lineKey);
    notifyListeners();
  }

  void updateQuantity(String lineKey, int quantity) {
    final existing = _items[lineKey];
    if (existing == null) return;
    if (quantity <= 0) {
      _items.remove(lineKey);
    } else {
      _items[lineKey] = existing.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
