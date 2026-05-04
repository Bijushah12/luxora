import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_order.dart';

class AdminAppUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final bool isAdmin;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const AdminAppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.isAdmin,
    this.createdAt,
    this.lastLoginAt,
  });

  factory AdminAppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final role = data['role'] as String? ?? 'customer';

    return AdminAppUser(
      id: snapshot.id,
      name: data['name'] as String? ?? data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber:
          data['phoneNumber'] as String? ?? data['phone'] as String? ?? '',
      role: role,
      isAdmin: data['isAdmin'] as bool? ?? role.toLowerCase() == 'admin',
      createdAt: _toDateTime(data['createdAt']),
      lastLoginAt: _toDateTime(data['lastLoginAt']),
    );
  }
}

class AdminUserActivity {
  final List<AdminCartItem> cartItems;
  final double cartTotal;
  final List<AdminWishlistItem> wishlistItems;
  final List<AdminSavedAddress> addresses;
  final List<AdminOrder> orders;
  final List<AdminUserNotification> notifications;
  final DateTime? cartUpdatedAt;
  final DateTime? wishlistUpdatedAt;
  final DateTime? addressesUpdatedAt;
  final DateTime? notificationsUpdatedAt;

  const AdminUserActivity({
    required this.cartItems,
    required this.cartTotal,
    required this.wishlistItems,
    required this.addresses,
    required this.orders,
    required this.notifications,
    this.cartUpdatedAt,
    this.wishlistUpdatedAt,
    this.addressesUpdatedAt,
    this.notificationsUpdatedAt,
  });

  int get cartTotalItems {
    if (cartItems.isEmpty) {
      return 0;
    }
    return cartItems.fold(0, (total, item) => total + item.quantity);
  }

  int get wishlistCount => wishlistItems.length;
  int get addressCount => addresses.length;
  int get orderCount => orders.length;
  int get notificationCount => notifications.length;

  int get unreadNotificationCount {
    return notifications.where((notification) => !notification.isRead).length;
  }

  double get totalSpent {
    return orders.fold(0, (total, order) => total + order.totalAmount);
  }

  DateTime? get lastOrderAt {
    if (orders.isEmpty) {
      return null;
    }
    return orders.first.createdAt;
  }

  factory AdminUserActivity.empty() {
    return const AdminUserActivity(
      cartItems: [],
      cartTotal: 0,
      wishlistItems: [],
      addresses: [],
      orders: [],
      notifications: [],
    );
  }

  factory AdminUserActivity.fromData({
    Map<String, dynamic>? cartData,
    Map<String, dynamic>? wishlistData,
    Map<String, dynamic>? addressesData,
    Map<String, dynamic>? notificationsData,
    required List<AdminOrder> orders,
  }) {
    final cartItems = _listFrom(cartData?['items'])
        .map(AdminCartItem.fromDynamic)
        .where((item) => item.name.trim().isNotEmpty)
        .toList(growable: false);
    final wishlistItems = _listFrom(wishlistData?['items'])
        .map(AdminWishlistItem.fromDynamic)
        .where((item) => item.name.trim().isNotEmpty)
        .toList(growable: false);
    final addresses = _listFrom(addressesData?['addresses'])
        .map(AdminSavedAddress.fromDynamic)
        .where((address) => address.addressLine.trim().isNotEmpty)
        .toList(growable: false);
    final notifications = _listFrom(notificationsData?['items'])
        .map(AdminUserNotification.fromDynamic)
        .where((notification) => notification.title.trim().isNotEmpty)
        .toList(growable: false);

    final rawCartTotal = cartData?['totalPrice'];

    return AdminUserActivity(
      cartItems: cartItems,
      cartTotal: rawCartTotal == null
          ? _cartTotal(cartItems)
          : _toDouble(rawCartTotal),
      wishlistItems: wishlistItems,
      addresses: addresses,
      orders: orders,
      notifications: notifications,
      cartUpdatedAt: _toDateTime(cartData?['updatedAt']),
      wishlistUpdatedAt: _toDateTime(wishlistData?['updatedAt']),
      addressesUpdatedAt: _toDateTime(addressesData?['updatedAt']),
      notificationsUpdatedAt: _toDateTime(notificationsData?['updatedAt']),
    );
  }
}

class AdminCartItem {
  final String productId;
  final String name;
  final String brand;
  final String category;
  final String imageUrl;
  final double price;
  final int quantity;

  const AdminCartItem({
    required this.productId,
    required this.name,
    required this.brand,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory AdminCartItem.fromDynamic(dynamic value) {
    final data = _toMap(value);
    final watch = _toMap(data['watch'] ?? data['product']);
    final quantity = _toInt(data['quantity'] ?? data['qty'] ?? 1);

    return AdminCartItem(
      productId: _string(data['productId'] ?? data['id'] ?? watch['id']),
      name: _string(data['name'] ?? data['title'] ?? watch['name']),
      brand: _string(data['brand'] ?? watch['brand']),
      category: _string(data['category'] ?? watch['category']),
      imageUrl: _string(
        data['imageUrl'] ??
            data['image'] ??
            watch['imageUrl'] ??
            watch['image'],
      ),
      price: _toDouble(data['price'] ?? watch['price']),
      quantity: quantity <= 0 ? 1 : quantity,
    );
  }
}

class AdminWishlistItem {
  final String productId;
  final String name;
  final String brand;
  final String category;
  final String imageUrl;
  final double price;

  const AdminWishlistItem({
    required this.productId,
    required this.name,
    required this.brand,
    required this.category,
    required this.imageUrl,
    required this.price,
  });

  factory AdminWishlistItem.fromDynamic(dynamic value) {
    final data = _toMap(value);

    return AdminWishlistItem(
      productId: _string(data['productId'] ?? data['id']),
      name: _string(data['name'] ?? data['title']),
      brand: _string(data['brand']),
      category: _string(data['category']),
      imageUrl: _string(data['imageUrl'] ?? data['image']),
      price: _toDouble(data['price']),
    );
  }
}

class AdminSavedAddress {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String addressLine;
  final bool isDefault;

  const AdminSavedAddress({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.isDefault,
  });

  String get displayLabel {
    if (label.trim().isEmpty) {
      return isDefault ? 'Default address' : 'Saved address';
    }
    return label;
  }

  factory AdminSavedAddress.fromDynamic(dynamic value) {
    final data = _toMap(value);
    final line = _string(
      data['addressLine'] ?? data['line1'] ?? data['address'] ?? data['flat'],
    );

    return AdminSavedAddress(
      id: _string(data['id']),
      label: _string(data['label'] ?? data['addressType']),
      fullName: _string(data['fullName'] ?? data['name']),
      phone: _string(data['phone']),
      addressLine: line,
      isDefault: data['isDefault'] as bool? ?? data['makeDefault'] == true,
    );
  }
}

class AdminUserNotification {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final DateTime? createdAt;
  final bool isRead;

  const AdminUserNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.isRead,
  });

  factory AdminUserNotification.fromDynamic(dynamic value) {
    final data = _toMap(value);

    return AdminUserNotification(
      id: _string(data['id']),
      type: _string(data['type']),
      title: _string(data['title']),
      subtitle: _string(data['subtitle']),
      createdAt: _toDateTime(data['createdAt']),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}

double _cartTotal(List<AdminCartItem> items) {
  return items.fold(0, (total, item) => total + item.subtotal);
}

List<dynamic> _listFrom(dynamic value) {
  if (value is Iterable) {
    return value.toList(growable: false);
  }
  return const [];
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
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

double _toDouble(dynamic value) {
  if (value is int) {
    return value.toDouble();
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

DateTime? _toDateTime(dynamic value) {
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
