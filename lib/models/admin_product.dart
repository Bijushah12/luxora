import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProduct {
  static const categories = ['Men', 'Women', 'Luxury', 'Sports', 'Smart'];

  final String id;
  final String name;
  final String description;
  final double price;
  final double discount;
  final String category;
  final String imageUrl;
  final String imagePath;
  final String brand;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discount,
    required this.category,
    required this.imageUrl,
    required this.imagePath,
    this.brand = 'Luxora',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  double get discountedPrice {
    if (discount <= 0) {
      return price;
    }
    return price - (price * (discount / 100));
  }

  bool get hasDiscount => discount > 0;

  factory AdminProduct.empty() {
    return const AdminProduct(
      id: '',
      name: '',
      description: '',
      price: 0,
      discount: 0,
      category: 'Men',
      imageUrl: '',
      imagePath: '',
    );
  }

  factory AdminProduct.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return AdminProduct(
      id: snapshot.id,
      name: data['name'] as String? ?? data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: _toDouble(data['price']),
      discount: _toDouble(data['discount']),
      category: data['category'] as String? ?? 'Men',
      imageUrl: data['imageUrl'] as String? ?? data['image'] as String? ?? '',
      imagePath: data['imagePath'] as String? ?? '',
      brand: data['brand'] as String? ?? 'Luxora',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'discount': discount,
      'category': category,
      'imageUrl': imageUrl,
      'image': imageUrl,
      'imagePath': imagePath,
      'brand': brand,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AdminProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discount,
    String? category,
    String? imageUrl,
    String? imagePath,
    String? brand,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      brand: brand ?? this.brand,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _toDouble(dynamic value) {
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

  static DateTime? _toDateTime(dynamic value) {
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
}
