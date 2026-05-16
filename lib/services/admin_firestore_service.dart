import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_broadcast_notification.dart';
import '../models/admin_order.dart';
import '../models/admin_product.dart';
import '../models/admin_coupon.dart';
import '../models/admin_storefront_settings.dart';
import '../models/admin_user.dart';

class AdminDashboardStats {
  final int usersCount;
  final int ordersCount;
  final int productsCount;
  final int activeProductsCount;
  final int pendingOrdersCount;
  final int ordersTodayCount;
  final int cartItemsCount;
  final int wishlistItemsCount;
  final int addressesCount;
  final double totalRevenue;
  final double luxuryRevenue;
  final double budgetRevenue;
  final String topSellingWatchName;
  final String topSellingWatchImageUrl;
  final int topSellingWatchQuantity;
  final Map<String, double> categorySales;
  final Map<String, double> brandSales;
  final List<AdminChartPoint> weeklySales;
  final List<AdminChartPoint> monthlySales;
  final List<AdminProduct> lowStockProducts;
  final List<AdminSmartAlert> smartAlerts;
  final List<AdminOrder> recentOrders;

  const AdminDashboardStats({
    required this.usersCount,
    required this.ordersCount,
    required this.productsCount,
    required this.activeProductsCount,
    required this.pendingOrdersCount,
    required this.ordersTodayCount,
    required this.cartItemsCount,
    required this.wishlistItemsCount,
    required this.addressesCount,
    required this.totalRevenue,
    required this.luxuryRevenue,
    required this.budgetRevenue,
    required this.topSellingWatchName,
    required this.topSellingWatchImageUrl,
    required this.topSellingWatchQuantity,
    required this.categorySales,
    required this.brandSales,
    required this.weeklySales,
    required this.monthlySales,
    required this.lowStockProducts,
    required this.smartAlerts,
    required this.recentOrders,
  });

  factory AdminDashboardStats.empty() {
    return const AdminDashboardStats(
      usersCount: 0,
      ordersCount: 0,
      productsCount: 0,
      activeProductsCount: 0,
      pendingOrdersCount: 0,
      ordersTodayCount: 0,
      cartItemsCount: 0,
      wishlistItemsCount: 0,
      addressesCount: 0,
      totalRevenue: 0,
      luxuryRevenue: 0,
      budgetRevenue: 0,
      topSellingWatchName: 'No sales yet',
      topSellingWatchImageUrl: '',
      topSellingWatchQuantity: 0,
      categorySales: {},
      brandSales: {},
      weeklySales: [],
      monthlySales: [],
      lowStockProducts: [],
      smartAlerts: [],
      recentOrders: [],
    );
  }
}

class AdminChartPoint {
  final String label;
  final double value;

  const AdminChartPoint({required this.label, required this.value});
}

class AdminSmartAlert {
  final String title;
  final String message;
  final String level;

  const AdminSmartAlert({
    required this.title,
    required this.message,
    required this.level,
  });
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

  CollectionReference<Map<String, dynamic>> get _admins =>
      _firestore.collection('admins');

  CollectionReference<Map<String, dynamic>> get _carts =>
      _firestore.collection('carts');

  CollectionReference<Map<String, dynamic>> get _wishlists =>
      _firestore.collection('wishlists');

  CollectionReference<Map<String, dynamic>> get _addresses =>
      _firestore.collection('addresses');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get _coupons =>
      _firestore.collection('coupons');

  CollectionReference<Map<String, dynamic>> get _adminNotifications =>
      _firestore.collection('admin_notifications');

  DocumentReference<Map<String, dynamic>> get _storefrontSettings =>
      _firestore.collection('admin_settings').doc('storefront');

  Stream<List<AdminProduct>> productsStream() {
    return _products.snapshots().map(
      (snapshot) => _sortProductsNewestFirst(
        snapshot.docs.map(AdminProduct.fromFirestore).toList(growable: false),
      ),
    );
  }

  Stream<AdminStorefrontSettings> storefrontSettingsStream() {
    return _storefrontSettings.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return AdminStorefrontSettings.defaults();
      }
      return AdminStorefrontSettings.fromFirestore(snapshot);
    });
  }

  Future<void> saveStorefrontSettings(AdminStorefrontSettings settings) {
    return _storefrontSettings.set(settings.toFirestore());
  }

  Future<void> addProduct(AdminProduct product) async {
    final productRef = _products.doc();
    final data = product.toFirestore()
      ..addAll({
        'id': productRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    await productRef.set(data);
  }

  Future<void> updateProduct(AdminProduct product) {
    return _products.doc(product.id).update(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) {
    return _products.doc(productId).delete();
  }

  Stream<List<AdminCoupon>> couponsStream() {
    return _coupons.snapshots().map((snapshot) {
      final coupons = snapshot.docs
          .map(AdminCoupon.fromFirestore)
          .toList(growable: false);
      coupons.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return coupons;
    });
  }

  Future<void> saveCoupon(AdminCoupon coupon) {
    final data = coupon.toFirestore();
    if (coupon.id.isEmpty) {
      data['createdAt'] = FieldValue.serverTimestamp();
      return _coupons.add(data);
    }
    return _coupons.doc(coupon.id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteCoupon(String couponId) {
    return _coupons.doc(couponId).delete();
  }

  Stream<List<AdminBroadcastNotification>> adminNotificationsStream() {
    return _adminNotifications.snapshots().map((snapshot) {
      final notifications = snapshot.docs
          .map(AdminBroadcastNotification.fromFirestore)
          .toList(growable: false);
      notifications.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return notifications;
    });
  }

  Future<void> saveAdminNotification(AdminBroadcastNotification notification) {
    final data = notification.toFirestore();
    if (notification.id.isEmpty) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['status'] = notification.isScheduled ? 'scheduled' : 'draft';
      return _adminNotifications.add(data);
    }
    return _adminNotifications
        .doc(notification.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deleteAdminNotification(String notificationId) {
    return _adminNotifications.doc(notificationId).delete();
  }

  Future<void> sendAdminNotification(AdminBroadcastNotification notification) {
    final data = notification.toFirestore()
      ..addAll({'status': 'queued', 'queuedAt': FieldValue.serverTimestamp()});
    if (notification.id.isEmpty) {
      data['createdAt'] = FieldValue.serverTimestamp();
      return _adminNotifications.add(data);
    }
    return _adminNotifications
        .doc(notification.id)
        .set(data, SetOptions(merge: true));
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
      'statusHistory': FieldValue.arrayUnion([
        {'status': status, 'at': Timestamp.now()},
      ]),
    });
  }

  Stream<List<AdminAppUser>> usersStream() {
    late final StreamController<List<AdminAppUser>> controller;
    QuerySnapshot<Map<String, dynamic>>? usersSnapshot;
    QuerySnapshot<Map<String, dynamic>>? adminsSnapshot;
    final subscriptions = <StreamSubscription>[];

    void emit() {
      if (controller.isClosed) {
        return;
      }

      final usersById = <String, AdminAppUser>{};
      for (final doc
          in usersSnapshot?.docs ??
              const <QueryDocumentSnapshot<Map<String, dynamic>>>[]) {
        usersById[doc.id] = AdminAppUser.fromFirestore(doc);
      }

      for (final doc
          in adminsSnapshot?.docs ??
              const <QueryDocumentSnapshot<Map<String, dynamic>>>[]) {
        final admin = _adminUserFromFirestore(doc);
        final existingId = usersById.containsKey(doc.id)
            ? doc.id
            : _userIdForEmail(usersById, admin.email);
        usersById[existingId ?? doc.id] = _mergeAdminWithUser(
          existingId == null ? null : usersById[existingId],
          admin,
        );
      }

      controller.add(_sortUsersNewestFirst(usersById.values.toList()));
    }

    void addError(Object error, StackTrace stackTrace) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<List<AdminAppUser>>(
      onListen: () {
        subscriptions
          ..add(
            _users.snapshots().listen((snapshot) {
              usersSnapshot = snapshot;
              emit();
            }, onError: addError),
          )
          ..add(
            _admins.snapshots().listen((snapshot) {
              adminsSnapshot = snapshot;
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

  Future<void> updateUserBlocked(String userId, bool isBlocked) {
    return _users.doc(userId).update({
      'isBlocked': isBlocked,
      'blocked': isBlocked,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  AdminAppUser _adminUserFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final active = data['active'] != false;
    return AdminAppUser(
      id: snapshot.id,
      name: _firstNonEmpty([
        _string(data['name']),
        _string(data['displayName']),
        _string(data['fullName']),
      ]),
      email: _string(data['email']),
      phoneNumber: _string(data['phoneNumber'] ?? data['phone']),
      role: 'admin',
      isAdmin: true,
      isBlocked:
          !active || data['isBlocked'] == true || data['blocked'] == true,
      createdAt: _dateTimeFrom(data['createdAt']),
      lastLoginAt: _dateTimeFrom(data['lastLoginAt']),
    );
  }

  AdminAppUser _mergeAdminWithUser(AdminAppUser? user, AdminAppUser admin) {
    if (user == null) {
      return admin;
    }

    return AdminAppUser(
      id: user.id,
      name: user.name.trim().isNotEmpty ? user.name : admin.name,
      email: user.email.trim().isNotEmpty ? user.email : admin.email,
      phoneNumber: user.phoneNumber.trim().isNotEmpty
          ? user.phoneNumber
          : admin.phoneNumber,
      role: 'admin',
      isAdmin: true,
      isBlocked: user.isBlocked || admin.isBlocked,
      createdAt: user.createdAt ?? admin.createdAt,
      lastLoginAt: user.lastLoginAt ?? admin.lastLoginAt,
    );
  }

  String? _userIdForEmail(Map<String, AdminAppUser> usersById, String email) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      return null;
    }

    for (final entry in usersById.entries) {
      if (entry.value.email.trim().toLowerCase() == normalizedEmail) {
        return entry.key;
      }
    }
    return null;
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
      _admins.get(),
      _orders.get(),
      _products.get(),
      _carts.get(),
      _wishlists.get(),
      _addresses.get(),
    ]);

    final usersSnapshot = results[0];
    final adminsSnapshot = results[1];
    final ordersSnapshot = results[2];
    final productsSnapshot = results[3];
    final cartsSnapshot = results[4];
    final wishlistsSnapshot = results[5];
    final addressesSnapshot = results[6];
    final totalUserIds = {
      ...usersSnapshot.docs.map((doc) => doc.id),
      ...adminsSnapshot.docs.map((doc) => doc.id),
    };
    final orders = _sortOrdersNewestFirst(
      ordersSnapshot.docs.map(AdminOrder.fromFirestore).toList(growable: false),
    );
    final products = productsSnapshot.docs
        .map(AdminProduct.fromFirestore)
        .toList(growable: false);
    final productById = {for (final product in products) product.id: product};
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final lowStockProducts = [
      ...products.where((product) => product.isLowStock),
    ]..sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));

    final topSelling = _topSellingWatch(orders, productById);
    final categorySales = _categorySales(orders, productById);
    final brandSales = _brandSales(orders, productById);
    final weeklySales = _salesForLastSevenDays(orders, now);
    final monthlySales = _salesForLastSixMonths(orders, now);
    final luxurySplit = _luxuryBudgetSplit(orders, productById);
    final ordersTodayCount = orders
        .where(
          (order) =>
              order.createdAt != null && !order.createdAt!.isBefore(todayStart),
        )
        .length;
    final pendingOrdersCount = orders
        .where(
          (order) =>
              AdminOrderStatus.normalize(order.status) ==
              AdminOrderStatus.pending,
        )
        .length;
    final smartAlerts = _buildSmartAlerts(
      ordersTodayCount: ordersTodayCount,
      pendingOrdersCount: pendingOrdersCount,
      lowStockProducts: lowStockProducts,
      topSelling: topSelling,
    );

    return AdminDashboardStats(
      usersCount: totalUserIds.length,
      ordersCount: ordersSnapshot.size,
      productsCount: productsSnapshot.size,
      activeProductsCount: products.where((product) => product.isActive).length,
      pendingOrdersCount: pendingOrdersCount,
      ordersTodayCount: ordersTodayCount,
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
      luxuryRevenue: luxurySplit.luxury,
      budgetRevenue: luxurySplit.budget,
      topSellingWatchName: topSelling.name,
      topSellingWatchImageUrl: topSelling.imageUrl,
      topSellingWatchQuantity: topSelling.quantity,
      categorySales: categorySales,
      brandSales: brandSales,
      weeklySales: weeklySales,
      monthlySales: monthlySales,
      lowStockProducts: lowStockProducts.take(6).toList(growable: false),
      smartAlerts: smartAlerts,
      recentOrders: orders.take(6).toList(growable: false),
    );
  }

  _TopSellingWatch _topSellingWatch(
    List<AdminOrder> orders,
    Map<String, AdminProduct> productById,
  ) {
    final quantities = <String, int>{};
    final names = <String, String>{};
    final images = <String, String>{};

    for (final order in orders) {
      for (final item in order.items) {
        final key = item.productId.trim().isNotEmpty
            ? item.productId.trim()
            : item.name.trim();
        if (key.isEmpty) {
          continue;
        }
        final product = _productForItem(item, productById);
        quantities[key] = (quantities[key] ?? 0) + item.quantity;
        names[key] = item.name.trim().isNotEmpty
            ? item.name
            : product?.name ?? 'Watch';
        images[key] = item.imageUrl.trim().isNotEmpty
            ? item.imageUrl
            : product?.primaryImageUrl ?? '';
      }
    }

    if (quantities.isEmpty) {
      return const _TopSellingWatch(
        name: 'No sales yet',
        imageUrl: '',
        quantity: 0,
      );
    }

    final top = quantities.entries.reduce(
      (left, right) => left.value >= right.value ? left : right,
    );

    return _TopSellingWatch(
      name: names[top.key] ?? 'Watch',
      imageUrl: images[top.key] ?? '',
      quantity: top.value,
    );
  }

  Map<String, double> _categorySales(
    List<AdminOrder> orders,
    Map<String, AdminProduct> productById,
  ) {
    final sales = <String, double>{};
    for (final order in orders) {
      for (final item in order.items) {
        final category = _categoryForItem(item, productById);
        sales[category] = (sales[category] ?? 0) + item.subtotal;
      }
    }
    return _sortMetricMap(sales);
  }

  Map<String, double> _brandSales(
    List<AdminOrder> orders,
    Map<String, AdminProduct> productById,
  ) {
    final sales = <String, double>{};
    for (final order in orders) {
      for (final item in order.items) {
        final brand = _brandForItem(item, productById);
        sales[brand] = (sales[brand] ?? 0) + item.subtotal;
      }
    }
    return _sortMetricMap(sales);
  }

  List<AdminChartPoint> _salesForLastSevenDays(
    List<AdminOrder> orders,
    DateTime now,
  ) {
    final days = [
      for (var index = 6; index >= 0; index--)
        DateTime(now.year, now.month, now.day).subtract(Duration(days: index)),
    ];
    final totals = {for (final day in days) _dateKey(day): 0.0};

    for (final order in orders) {
      final createdAt = order.createdAt;
      if (createdAt == null) {
        continue;
      }
      final key = _dateKey(createdAt);
      if (totals.containsKey(key)) {
        totals[key] = totals[key]! + order.totalAmount;
      }
    }

    return days
        .map(
          (day) => AdminChartPoint(
            label: _shortWeekday(day.weekday),
            value: totals[_dateKey(day)] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  List<AdminChartPoint> _salesForLastSixMonths(
    List<AdminOrder> orders,
    DateTime now,
  ) {
    final months = [
      for (var index = 5; index >= 0; index--) _monthStart(now, index),
    ];
    final totals = {for (final month in months) _monthKey(month): 0.0};

    for (final order in orders) {
      final createdAt = order.createdAt;
      if (createdAt == null) {
        continue;
      }
      final key = _monthKey(createdAt);
      if (totals.containsKey(key)) {
        totals[key] = totals[key]! + order.totalAmount;
      }
    }

    return months
        .map(
          (month) => AdminChartPoint(
            label: _shortMonth(month.month),
            value: totals[_monthKey(month)] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  _LuxuryBudgetSplit _luxuryBudgetSplit(
    List<AdminOrder> orders,
    Map<String, AdminProduct> productById,
  ) {
    var luxury = 0.0;
    var budget = 0.0;

    for (final order in orders) {
      if (order.items.isEmpty) {
        budget += order.totalAmount;
        continue;
      }
      for (final item in order.items) {
        final product = _productForItem(item, productById);
        final isLuxury =
            product?.isLuxury == true ||
            _categoryForItem(item, productById).toLowerCase() == 'luxury' ||
            item.price >= 100000;
        if (isLuxury) {
          luxury += item.subtotal;
        } else {
          budget += item.subtotal;
        }
      }
    }

    return _LuxuryBudgetSplit(luxury: luxury, budget: budget);
  }

  List<AdminSmartAlert> _buildSmartAlerts({
    required int ordersTodayCount,
    required int pendingOrdersCount,
    required List<AdminProduct> lowStockProducts,
    required _TopSellingWatch topSelling,
  }) {
    final alerts = <AdminSmartAlert>[];
    if (ordersTodayCount > 0) {
      alerts.add(
        AdminSmartAlert(
          title: 'New orders today',
          message: '$ordersTodayCount fresh orders need review.',
          level: 'success',
        ),
      );
    }
    if (pendingOrdersCount > 0) {
      alerts.add(
        AdminSmartAlert(
          title: 'Pending fulfillment',
          message: '$pendingOrdersCount orders are still pending.',
          level: 'warning',
        ),
      );
    }
    if (lowStockProducts.isNotEmpty) {
      alerts.add(
        AdminSmartAlert(
          title: 'Low stock warning',
          message:
              '${lowStockProducts.first.name} has only ${lowStockProducts.first.stockQuantity} pieces left.',
          level: 'danger',
        ),
      );
    }
    if (topSelling.quantity >= 3) {
      alerts.add(
        AdminSmartAlert(
          title: 'High demand watch',
          message:
              '${topSelling.name} is leading sales with ${topSelling.quantity} units.',
          level: 'info',
        ),
      );
    }
    if (alerts.isEmpty) {
      alerts.add(
        const AdminSmartAlert(
          title: 'Store health looks stable',
          message: 'No urgent operations alert right now.',
          level: 'success',
        ),
      );
    }
    return alerts.take(4).toList(growable: false);
  }

  AdminProduct? _productForItem(
    AdminOrderItem item,
    Map<String, AdminProduct> productById,
  ) {
    final direct = productById[item.productId];
    if (direct != null) {
      return direct;
    }
    final name = item.name.toLowerCase().trim();
    if (name.isEmpty) {
      return null;
    }
    for (final product in productById.values) {
      if (product.name.toLowerCase().trim() == name) {
        return product;
      }
    }
    return null;
  }

  String _categoryForItem(
    AdminOrderItem item,
    Map<String, AdminProduct> productById,
  ) {
    if (item.category.trim().isNotEmpty) {
      return item.category;
    }
    final product = _productForItem(item, productById);
    if (product != null && product.category.trim().isNotEmpty) {
      return product.category;
    }
    return item.price >= 100000 ? 'Luxury' : 'Budget';
  }

  String _brandForItem(
    AdminOrderItem item,
    Map<String, AdminProduct> productById,
  ) {
    if (item.brand.trim().isNotEmpty) {
      return item.brand;
    }
    final product = _productForItem(item, productById);
    if (product != null && product.brand.trim().isNotEmpty) {
      return product.brand;
    }
    return 'Luxora';
  }

  Map<String, double> _sortMetricMap(Map<String, double> values) {
    final entries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map<String, double>.fromEntries(entries);
  }

  DateTime _monthStart(DateTime now, int monthsAgo) {
    return DateTime(now.year, now.month - monthsAgo);
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _monthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  String _shortWeekday(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[(weekday - 1).clamp(0, 6).toInt()];
  }

  String _shortMonth(int month) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return labels[(month - 1).clamp(0, 11).toInt()];
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

  DateTime? _dateTimeFrom(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final clean = value.trim();
      if (clean.isNotEmpty) {
        return clean;
      }
    }
    return '';
  }

  String _string(dynamic value) => value?.toString() ?? '';

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

class _TopSellingWatch {
  final String name;
  final String imageUrl;
  final int quantity;

  const _TopSellingWatch({
    required this.name,
    required this.imageUrl,
    required this.quantity,
  });
}

class _LuxuryBudgetSplit {
  final double luxury;
  final double budget;

  const _LuxuryBudgetSplit({required this.luxury, required this.budget});
}
