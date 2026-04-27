import 'package:flutter/material.dart';
import '../models/watch_model.dart';

class CartProvider extends ChangeNotifier {

  // 🔥 id → (Watch + quantity)
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  // ✅ Add to Cart
  void addToCart(Watch watch) {
    if (_items.containsKey(watch.id)) {
      _items[watch.id]!.quantity++;
    } else {
      _items[watch.id] = CartItem(watch: watch, quantity: 1);
    }
    notifyListeners();
  }

  // ➕ Increase Quantity
  void increaseQty(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
      notifyListeners();
    }
  }

  // ➖ Decrease Quantity
  void decreaseQty(String id) {
    if (_items.containsKey(id)) {
      if (_items[id]!.quantity > 1) {
        _items[id]!.quantity--;
      } else {
        _items.remove(id);
      }
      notifyListeners();
    }
  }

  // ❌ Remove Item
  void removeFromCart(String id) {
    _items.remove(id);
    notifyListeners();
  }

  // 🧮 Total Items Count
  int get totalItems {
    int total = 0;
    _items.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  // 💰 Total Price
  double get totalPrice {
    double total = 0;
    _items.forEach((key, value) {
      total += value.watch.price * value.quantity;
    });
    return total;
  }

  // 🧹 Clear Cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// 🔥 Cart Item Model
class CartItem {
  final Watch watch;
  int quantity;

  CartItem({
    required this.watch,
    required this.quantity,
  });
}