import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderStatus {
  static const pending = 'Pending';
  static const shipped = 'Shipped';
  static const delivered = 'Delivered';

  static const values = [pending, shipped, delivered];

  static String normalize(String? value) {
    if (value == null || value.trim().isEmpty) {
      return pending;
    }

    final lower = value.trim().toLowerCase();
    for (final status in values) {
      if (status.toLowerCase() == lower) {
        return status;
      }
    }
    return pending;
  }
}

class AdminOrder {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final List<AdminOrderItem> items;
  final double totalAmount;
  final AdminOrderAddress address;
  final String status;
  final DateTime? createdAt;

  const AdminOrder({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.items,
    required this.totalAmount,
    required this.address,
    required this.status,
    this.createdAt,
  });

  String get customerDisplayName {
    if (userName.trim().isNotEmpty) {
      return userName;
    }
    if (userEmail.trim().isNotEmpty) {
      return userEmail;
    }
    return 'Guest customer';
  }

  factory AdminOrder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final user = _toMap(data['userDetails'] ?? data['user']);
    final rawItems = data['products'] ?? data['items'] ?? const [];

    return AdminOrder(
      id: snapshot.id,
      userId: _string(data['userId'] ?? data['uid'] ?? user['uid']),
      userName: _string(
        data['userName'] ?? data['customerName'] ?? user['name'],
      ),
      userEmail: _string(data['userEmail'] ?? user['email']),
      userPhone: _string(
        data['userPhone'] ?? data['phone'] ?? user['phoneNumber'],
      ),
      items: _toItems(rawItems),
      totalAmount: _toDouble(
        data['totalAmount'] ?? data['grandTotal'] ?? data['total'],
      ),
      address: AdminOrderAddress.fromDynamic(
        data['address'] ?? data['shippingAddress'],
      ),
      status: AdminOrderStatus.normalize(data['status'] as String?),
      createdAt: _toDateTime(data['createdAt'] ?? data['orderedAt']),
    );
  }

  static List<AdminOrderItem> _toItems(dynamic value) {
    if (value is! Iterable) {
      return const [];
    }
    return value
        .map((item) => AdminOrderItem.fromDynamic(item))
        .where((item) => item.name.trim().isNotEmpty)
        .toList(growable: false);
  }
}

class AdminOrderItem {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;

  const AdminOrderItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory AdminOrderItem.fromDynamic(dynamic value) {
    final data = _toMap(value);
    final nestedProduct = _toMap(data['product'] ?? data['watch']);
    final quantity = _toInt(data['quantity'] ?? data['qty'] ?? 1);
    final price = _toDouble(
      data['price'] ?? nestedProduct['price'] ?? data['unitPrice'],
    );

    return AdminOrderItem(
      productId: _string(
        data['productId'] ?? data['id'] ?? nestedProduct['id'],
      ),
      name: _string(
        data['name'] ?? nestedProduct['name'] ?? nestedProduct['title'],
      ),
      imageUrl: _string(
        data['imageUrl'] ?? data['image'] ?? nestedProduct['image'],
      ),
      price: price,
      quantity: quantity <= 0 ? 1 : quantity,
    );
  }
}

class AdminOrderAddress {
  final String fullName;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;

  const AdminOrderAddress({
    this.fullName = '',
    this.phone = '',
    this.line1 = '',
    this.line2 = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
  });

  String get singleLine {
    final parts = [
      line1,
      line2,
      city,
      state,
      pincode,
    ].where((part) => part.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return 'No address provided';
    }
    return parts.join(', ');
  }

  factory AdminOrderAddress.fromDynamic(dynamic value) {
    if (value is String) {
      return AdminOrderAddress(line1: value);
    }

    final data = _toMap(value);
    return AdminOrderAddress(
      fullName: _string(data['fullName'] ?? data['name']),
      phone: _string(data['phone']),
      line1: _string(
        data['addressLine'] ?? data['line1'] ?? data['address'] ?? data['flat'],
      ),
      line2: _string(data['line2'] ?? data['landmark']),
      city: _string(data['city']),
      state: _string(data['state']),
      pincode: _string(data['pincode'] ?? data['zip']),
    );
  }
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
