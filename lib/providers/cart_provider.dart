import 'package:flutter/material.dart';
import '../models/watch_model.dart';

class CartProvider extends ChangeNotifier {

  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  void addToCart(Watch watch) {
    if (_items.containsKey(watch.id)) {
      _items[watch.id]!.quantity++;
    } else {
      _items[watch.id] = CartItem(watch: watch, quantity: 1);
    }
    notifyListeners();
  }

  void increaseQty(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
      notifyListeners();
    }
  }

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

  void removeFromCart(String id) {
    _items.remove(id);
    notifyListeners();
  }

  int get totalItems {
    int total = 0;
    _items.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  double get totalPrice {
    double total = 0;
    _items.forEach((key, value) {
      total += value.watch.price * value.quantity;
    });
    return total;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final Watch watch;
  int quantity;

  CartItem({
    required this.watch,
    required this.quantity,
  });
}