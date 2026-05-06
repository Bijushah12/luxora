import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_order.dart';
import '../models/admin_product.dart';
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

  CollectionReference<Map<String, dynamic>> get _carts =>
      _firestore.collection('carts');

  CollectionReference<Map<String, dynamic>> get _wishlists =>
      _firestore.collection('wishlists');

  CollectionReference<Map<String, dynamic>> get _addresses =>
      _firestore.collection('addresses');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

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
      'statusHistory': FieldValue.arrayUnion([
        {'status': status, 'at': Timestamp.now()},
      ]),
    });
  }

  Stream<List<AdminAppUser>> usersStream() {
    return _users.snapshots().map(
      (snapshot) => _sortUsersNewestFirst(
        snapshot.docs.map(AdminAppUser.fromFirestore).toList(growable: false),
      ),
    );
  }

  Future<void> updateUserBlocked(String userId, bool isBlocked) {
    return _users.doc(userId).update({
      'isBlocked': isBlocked,
      'blocked': isBlocked,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
      usersCount: usersSnapshot.size,
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
