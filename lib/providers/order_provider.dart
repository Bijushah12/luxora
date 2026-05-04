import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/order_model.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSubscription;

  List<Order> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _disposed = false;

  OrderProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance {
    _authSubscription = _auth.authStateChanges().listen(_listenForUserOrders);
    _listenForUserOrders(_auth.currentUser);
  }

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection('orders');

  Future<Order> placeOrder({
    required Iterable<CartItem> cartItems,
    required double subtotal,
    required double shipping,
    required double tax,
    required double discount,
    required double total,
    required String paymentMethod,
    required String paymentStatus,
    required String transactionId,
    required String deliveryOption,
    required Map<String, dynamic> address,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Login before placing an order.',
      );
    }

    final items = cartItems
        .map(
          (item) => OrderItem(
            productId: item.watch.id,
            name: item.watch.name,
            brand: item.watch.brand,
            category: item.watch.category,
            imageUrl: item.watch.image,
            price: item.watch.price,
            quantity: item.quantity,
          ),
        )
        .toList(growable: false);

    if (items.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'empty-order',
        message: 'Cannot place an empty order.',
      );
    }

    final userName = _text(address['fullName']).isEmpty
        ? user.displayName ?? ''
        : _text(address['fullName']);
    final userPhone = _text(address['phone']);
    final userEmail = _text(address['email']).isEmpty
        ? user.email ?? ''
        : _text(address['email']);
    final orderRef = _ordersRef.doc();
    final order = Order(
      id: orderRef.id,
      userId: user.uid,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      items: items,
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      discount: discount,
      total: total,
      status: 'Pending',
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      transactionId: transactionId,
      deliveryOption: deliveryOption,
      address: {
        ...address,
        'fullName': userName,
        'email': userEmail,
        'phone': userPhone,
      },
    );

    await orderRef.set(order.toFirestore());
    return order;
  }

  Stream<List<Order>> userOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(const []);
    }

    return _ordersRef
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snapshot) => _sortNewestFirst(
            snapshot.docs.map(Order.fromFirestore).toList(growable: false),
          ),
        );
  }

  void _listenForUserOrders(User? user) {
    _ordersSubscription?.cancel();
    _orders = [];
    _errorMessage = null;

    if (user == null) {
      _isLoading = false;
      _safeNotify();
      return;
    }

    _isLoading = true;
    _safeNotify();

    _ordersSubscription = _ordersRef
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (snapshot) {
            _orders = _sortNewestFirst(
              snapshot.docs.map(Order.fromFirestore).toList(growable: false),
            );
            _isLoading = false;
            _errorMessage = null;
            _safeNotify();
          },
          onError: (Object error) {
            _orders = [];
            _isLoading = false;
            _errorMessage = error.toString();
            _safeNotify();
          },
        );
  }

  List<Order> _sortNewestFirst(List<Order> orders) {
    return [...orders]..sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
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
    _ordersSubscription?.cancel();
    super.dispose();
  }

  String _text(dynamic value) => value?.toString().trim() ?? '';
}
