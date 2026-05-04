import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import 'watch_model.dart';

class Order {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String transactionId;
  final String deliveryOption;
  final Map<String, dynamic> address;
  final DateTime? createdAt;

  const Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.transactionId,
    required this.deliveryOption,
    required this.address,
    this.createdAt,
  });

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userDetails': {
        'uid': userId,
        'name': userName,
        'email': userEmail,
        'phoneNumber': userPhone,
      },
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'discount': discount,
      'total': total,
      'totalAmount': total,
      'grandTotal': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,
      'deliveryOption': deliveryOption,
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final userDetails = _toMap(data['userDetails'] ?? data['user']);
    final items = _toItems(data['items'] ?? data['products']);

    return Order(
      id: snapshot.id,
      userId: _string(data['userId'] ?? data['uid'] ?? userDetails['uid']),
      userName: _string(
        data['userName'] ?? data['customerName'] ?? userDetails['name'],
      ),
      userEmail: _string(data['userEmail'] ?? userDetails['email']),
      userPhone: _string(
        data['userPhone'] ?? data['phone'] ?? userDetails['phoneNumber'],
      ),
      items: items,
      subtotal: _toDouble(data['subtotal']),
      shipping: _toDouble(data['shipping']),
      tax: _toDouble(data['tax']),
      discount: _toDouble(data['discount']),
      total: _toDouble(
        data['totalAmount'] ?? data['grandTotal'] ?? data['total'],
      ),
      status: _string(data['status']).isEmpty
          ? 'Pending'
          : _string(data['status']),
      paymentMethod: _string(data['paymentMethod']),
      paymentStatus: _string(data['paymentStatus']),
      transactionId: _string(data['transactionId']),
      deliveryOption: _string(data['deliveryOption']),
      address: _toMap(data['address'] ?? data['shippingAddress']),
      createdAt: _toDateTime(data['createdAt'] ?? data['orderedAt']),
    );
  }

  static List<OrderItem> _toItems(dynamic value) {
    if (value is! Iterable) {
      return const [];
    }

    return value
        .map(OrderItem.fromDynamic)
        .where((item) => item.name.trim().isNotEmpty)
        .toList(growable: false);
  }
}

class OrderItem {
  final String productId;
  final String name;
  final String brand;
  final String category;
  final String imageUrl;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.brand,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  Watch get watch {
    return Watch(
      id: productId,
      name: name,
      brand: brand,
      price: price,
      image: imageUrl,
      description: '',
      category: category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'id': productId,
      'name': name,
      'brand': brand,
      'category': category,
      'imageUrl': imageUrl,
      'image': imageUrl,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory OrderItem.fromDynamic(dynamic value) {
    final data = _toMap(value);
    final nestedProduct = _toMap(data['product'] ?? data['watch']);
    final quantity = _toInt(data['quantity'] ?? data['qty'] ?? 1);

    return OrderItem(
      productId: _string(
        data['productId'] ?? data['id'] ?? nestedProduct['id'],
      ),
      name: _string(
        data['name'] ?? nestedProduct['name'] ?? nestedProduct['title'],
      ),
      brand: _string(data['brand'] ?? nestedProduct['brand']),
      category: _string(data['category'] ?? nestedProduct['category']),
      imageUrl: _string(
        data['imageUrl'] ?? data['image'] ?? nestedProduct['image'],
      ),
      price: _toDouble(data['price'] ?? nestedProduct['price']),
      quantity: quantity <= 0 ? 1 : quantity,
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
