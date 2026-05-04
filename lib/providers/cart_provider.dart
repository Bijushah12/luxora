import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/watch_model.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<User?>? _authSubscription;

  final Map<String, CartItem> _items = {};
  bool _isLoading = false;
  bool _disposed = false;

  CartProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance {
    _authSubscription = _auth.authStateChanges().listen(_loadCartForUser);
    _loadCartForUser(_auth.currentUser);
  }

  Map<String, CartItem> get items => Map.unmodifiable(_items);
  bool get isLoading => _isLoading;

  CollectionReference<Map<String, dynamic>> get _carts =>
      _firestore.collection('carts');

  void addToCart(Watch watch) {
    if (_items.containsKey(watch.id)) {
      _items[watch.id]!.quantity++;
    } else {
      _items[watch.id] = CartItem(watch: watch, quantity: 1);
    }
    _notifyAndSave();
  }

  void increaseQty(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
      _notifyAndSave();
    }
  }

  void decreaseQty(String id) {
    if (_items.containsKey(id)) {
      if (_items[id]!.quantity > 1) {
        _items[id]!.quantity--;
      } else {
        _items.remove(id);
      }
      _notifyAndSave();
    }
  }

  void removeFromCart(String id) {
    _items.remove(id);
    _notifyAndSave();
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
    _notifyAndSave();
  }

  Future<void> _loadCartForUser(User? user) async {
    _isLoading = true;
    _safeNotify();

    _items.clear();

    if (user == null) {
      _isLoading = false;
      _safeNotify();
      return;
    }

    try {
      final doc = await _carts.doc(user.uid).get();
      final data = doc.data();
      final rawItems = data?['items'];

      if (rawItems is Iterable) {
        for (final item in rawItems) {
          final cartItem = CartItem.fromMap(item);
          if (cartItem != null) {
            _items[cartItem.watch.id] = cartItem;
          }
        }
      }
    } catch (error) {
      debugPrint('Error loading cart: $error');
    }

    _isLoading = false;
    _safeNotify();
  }

  void _notifyAndSave() {
    _safeNotify();
    _saveCart();
  }

  Future<void> _saveCart() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _carts.doc(user.uid).set({
        'userId': user.uid,
        'items': _items.values.map((item) => item.toMap()).toList(),
        'totalItems': totalItems,
        'totalPrice': totalPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error) {
      debugPrint('Error saving cart: $error');
    }
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}

class CartItem {
  final Watch watch;
  int quantity;

  CartItem({required this.watch, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'watch': watch.toJson(),
      'quantity': quantity,
      'subtotal': watch.price * quantity,
    };
  }

  factory CartItem.fromWatch(Watch watch, int quantity) {
    return CartItem(watch: watch, quantity: quantity <= 0 ? 1 : quantity);
  }

  static CartItem? fromMap(dynamic value) {
    if (value is! Map) {
      return null;
    }

    final data = value.map((key, value) => MapEntry(key.toString(), value));
    final watchData = data['watch'];
    final quantity = _toInt(data['quantity'] ?? data['qty'] ?? 1);

    if (watchData is Map) {
      return CartItem.fromWatch(
        Watch.fromJson(
          watchData.map((key, value) => MapEntry(key.toString(), value)),
        ),
        quantity,
      );
    }

    return CartItem.fromWatch(Watch.fromJson(data), quantity);
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 1;
    }
    return 1;
  }
}
