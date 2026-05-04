import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_order.dart';
import '../models/admin_product.dart';
import '../models/admin_user.dart';

class AdminDashboardStats {
  final int usersCount;
  final int ordersCount;
  final int productsCount;
  final int activeProductsCount;
  final int pendingOrdersCount;
  final int cartItemsCount;
  final int wishlistItemsCount;
  final int addressesCount;
  final double totalRevenue;
  final List<AdminOrder> recentOrders;

  const AdminDashboardStats({
    required this.usersCount,
    required this.ordersCount,
    required this.productsCount,
    required this.activeProductsCount,
    required this.pendingOrdersCount,
    required this.cartItemsCount,
    required this.wishlistItemsCount,
    required this.addressesCount,
    required this.totalRevenue,
    required this.recentOrders,
  });

  factory AdminDashboardStats.empty() {
    return const AdminDashboardStats(
      usersCount: 0,
      ordersCount: 0,
      productsCount: 0,
      activeProductsCount: 0,
      pendingOrdersCount: 0,
      cartItemsCount: 0,
      wishlistItemsCount: 0,
      addressesCount: 0,
      totalRevenue: 0,
      recentOrders: [],
    );
  }
}

class AdminFirestoreService {
  final FirebaseFirestore _firestore;

  AdminFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _carts =>
      _firestore.collection('carts');

  CollectionReference<Map<String, dynamic>> get _wishlists =>
      _firestore.collection('wishlists');

  CollectionReference<Map<String, dynamic>> get _addresses =>
      _firestore.collection('addresses');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Stream<List<AdminProduct>> productsStream() {
    return _products.snapshots().map(
      (snapshot) => _sortProductsNewestFirst(
        snapshot.docs.map(AdminProduct.fromFirestore).toList(growable: false),
      ),
    );
  }

  Future<void> addProduct(AdminProduct product) async {
    final data = product.toFirestore()
      ..['createdAt'] = FieldValue.serverTimestamp();
    await _products.add(data);
  }

  Future<void> updateProduct(AdminProduct product) {
    return _products.doc(product.id).update(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) {
    return _products.doc(productId).delete();
  }

  Stream<List<AdminOrder>> ordersStream() {
    return _orders.snapshots().map(
      (snapshot) => _sortOrdersNewestFirst(
        snapshot.docs.map(AdminOrder.fromFirestore).toList(growable: false),
      ),
    );
  }

  Future<void> updateOrderStatus(String orderId, String status) {
    return _orders.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AdminAppUser>> usersStream() {
    return _users.snapshots().map(
      (snapshot) => _sortUsersNewestFirst(
        snapshot.docs.map(AdminAppUser.fromFirestore).toList(growable: false),
      ),
    );
  }

  Stream<AdminUserActivity> userActivityStream(String userId) {
    late final StreamController<AdminUserActivity> controller;

    DocumentSnapshot<Map<String, dynamic>>? cartSnapshot;
    DocumentSnapshot<Map<String, dynamic>>? wishlistSnapshot;
    DocumentSnapshot<Map<String, dynamic>>? addressesSnapshot;
    DocumentSnapshot<Map<String, dynamic>>? notificationsSnapshot;
    QuerySnapshot<Map<String, dynamic>>? ordersSnapshot;
    final subscriptions = <StreamSubscription>[];

    void emit() {
      if (controller.isClosed) {
        return;
      }

      final orders = _sortOrdersNewestFirst(
        ordersSnapshot?.docs
                .map(AdminOrder.fromFirestore)
                .toList(growable: false) ??
            const <AdminOrder>[],
      );

      controller.add(
        AdminUserActivity.fromData(
          cartData: cartSnapshot?.data(),
          wishlistData: wishlistSnapshot?.data(),
          addressesData: addressesSnapshot?.data(),
          notificationsData: notificationsSnapshot?.data(),
          orders: orders,
        ),
      );
    }

    void addError(Object error, StackTrace stackTrace) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<AdminUserActivity>(
      onListen: () {
        subscriptions
          ..add(
            _carts.doc(userId).snapshots().listen((snapshot) {
              cartSnapshot = snapshot;
              emit();
            }, onError: addError),
          )
          ..add(
            _wishlists.doc(userId).snapshots().listen((snapshot) {
              wishlistSnapshot = snapshot;
              emit();
            }, onError: addError),
          )
          ..add(
            _addresses.doc(userId).snapshots().listen((snapshot) {
              addressesSnapshot = snapshot;
              emit();
            }, onError: addError),
          )
          ..add(
            _notifications.doc(userId).snapshots().listen((snapshot) {
              notificationsSnapshot = snapshot;
              emit();
            }, onError: addError),
          )
          ..add(
            _orders.where('userId', isEqualTo: userId).snapshots().listen((
              snapshot,
            ) {
              ordersSnapshot = snapshot;
              emit();
            }, onError: addError),
          );
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );

    return controller.stream;
  }

  Future<AdminDashboardStats> fetchDashboardStats() async {
    final results = await Future.wait([
      _users.get(),
      _orders.get(),
      _products.get(),
      _carts.get(),
      _wishlists.get(),
      _addresses.get(),
    ]);

    final usersSnapshot = results[0];
    final ordersSnapshot = results[1];
    final productsSnapshot = results[2];
    final cartsSnapshot = results[3];
    final wishlistsSnapshot = results[4];
    final addressesSnapshot = results[5];
    final orders = _sortOrdersNewestFirst(
      ordersSnapshot.docs.map(AdminOrder.fromFirestore).toList(growable: false),
    );
    final products = productsSnapshot.docs
        .map(AdminProduct.fromFirestore)
        .toList(growable: false);

    return AdminDashboardStats(
      usersCount: usersSnapshot.size,
      ordersCount: ordersSnapshot.size,
      productsCount: productsSnapshot.size,
      activeProductsCount: products.where((product) => product.isActive).length,
      pendingOrdersCount: orders
          .where(
            (order) =>
                AdminOrderStatus.normalize(order.status) ==
                AdminOrderStatus.pending,
          )
          .length,
      cartItemsCount: cartsSnapshot.docs.fold(
        0,
        (total, doc) => total + _totalItemsFrom(doc.data(), 'items'),
      ),
      wishlistItemsCount: wishlistsSnapshot.docs.fold(
        0,
        (total, doc) => total + _totalItemsFrom(doc.data(), 'items'),
      ),
      addressesCount: addressesSnapshot.docs.fold(
        0,
        (total, doc) => total + _totalItemsFrom(doc.data(), 'addresses'),
      ),
      totalRevenue: orders.fold(0, (total, order) => total + order.totalAmount),
      recentOrders: orders.take(6).toList(growable: false),
    );
  }

  List<AdminProduct> _sortProductsNewestFirst(List<AdminProduct> products) {
    return [...products]
      ..sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
  }

  List<AdminOrder> _sortOrdersNewestFirst(List<AdminOrder> orders) {
    return [...orders]
      ..sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
  }

  List<AdminAppUser> _sortUsersNewestFirst(List<AdminAppUser> users) {
    return [...users]
      ..sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
  }

  int _compareNewestFirst(DateTime? a, DateTime? b) {
    final left = a ?? DateTime.fromMillisecondsSinceEpoch(0);
    final right = b ?? DateTime.fromMillisecondsSinceEpoch(0);
    return right.compareTo(left);
  }

  int _totalItemsFrom(Map<String, dynamic> data, String listField) {
    final explicitTotal = data['totalItems'];
    if (explicitTotal != null) {
      return _toInt(explicitTotal);
    }

    final explicitAddresses = data['totalAddresses'];
    if (explicitAddresses != null) {
      return _toInt(explicitAddresses);
    }

    final items = data[listField];
    if (items is Iterable) {
      if (listField == 'items') {
        var total = 0;
        for (final item in items) {
          if (item is Map) {
            total += _toInt(item['quantity'] ?? item['qty'] ?? 1);
          } else {
            total += 1;
          }
        }
        return total;
      }
      return items.length;
    }

    return 0;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
