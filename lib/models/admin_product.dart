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
  final List<String> imageUrls;
  final List<String> imagePaths;
  final String brand;
  final String dialColor;
  final String strapMaterial;
  final bool waterResistant;
  final String warranty;
  final int stockQuantity;
  final bool isFeatured;
  final bool isTrending;
  final bool isActive;
  final List<AdminWatchVariant> variants;
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
    this.imageUrls = const [],
    this.imagePaths = const [],
    this.brand = 'Luxora',
    this.dialColor = 'Black',
    this.strapMaterial = 'Stainless Steel',
    this.waterResistant = true,
    this.warranty = '2 Years',
    this.stockQuantity = 0,
    this.isFeatured = false,
    this.isTrending = false,
    this.isActive = true,
    this.variants = const [],
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

  String get primaryImageUrl {
    for (final image in imageUrls) {
      if (image.trim().isNotEmpty) {
        return image;
      }
    }
    return imageUrl;
  }

  String get primaryImagePath {
    for (final path in imagePaths) {
      if (path.trim().isNotEmpty) {
        return path;
      }
    }
    return imagePath;
  }

  bool get hasMultipleImages => imageUrls.length > 1;

  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  bool get isOutOfStock => stockQuantity <= 0;

  bool get isLuxury {
    return category.toLowerCase() == 'luxury' || discountedPrice >= 100000;
  }

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
    final imageUrl =
        data['imageUrl'] as String? ?? data['image'] as String? ?? '';
    final imagePath = data['imagePath'] as String? ?? '';
    final imageUrls = _mergePrimaryString(
      imageUrl,
      _imageUrlsFrom(data['imageUrls'] ?? data['images']),
    );
    final imagePaths = _mergePrimaryString(
      imagePath,
      _stringList(data['imagePaths']),
    );

    return AdminProduct(
      id: snapshot.id,
      name: data['name'] as String? ?? data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: _toDouble(data['price']),
      discount: _toDouble(data['discount']),
      category: data['category'] as String? ?? 'Men',
      imageUrl: imageUrl,
      imagePath: imagePath,
      imageUrls: imageUrls,
      imagePaths: imagePaths,
      brand: data['brand'] as String? ?? 'Luxora',
      dialColor: data['dialColor'] as String? ?? 'Black',
      strapMaterial: data['strapMaterial'] as String? ?? 'Stainless Steel',
      waterResistant: _toBool(
        data['waterResistant'] ?? data['isWaterResistant'],
        fallback: true,
      ),
      warranty: data['warranty'] as String? ?? '2 Years',
      stockQuantity: _toInt(
        data['stockQuantity'] ?? data['stock'] ?? data['quantity'],
      ),
      isFeatured: _toBool(data['isFeatured'] ?? data['featured']),
      isTrending: _toBool(data['isTrending'] ?? data['trending']),
      isActive: data['isActive'] as bool? ?? true,
      variants: _listFrom(data['variants'])
          .map(AdminWatchVariant.fromDynamic)
          .where((variant) => variant.label.trim().isNotEmpty)
          .toList(growable: false),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    final galleryUrls = _mergePrimaryString(imageUrl, imageUrls);
    final galleryPaths = _mergePrimaryString(imagePath, imagePaths);
    final primaryUrl = galleryUrls.isEmpty ? imageUrl : galleryUrls.first;
    final primaryPath = galleryPaths.isEmpty ? imagePath : galleryPaths.first;

    return {
      'name': name,
      'description': description,
      'price': price,
      'discount': discount,
      'category': category,
      'imageUrl': primaryUrl,
      'image': primaryUrl,
      'imagePath': primaryPath,
      'imageUrls': galleryUrls,
      'imagePaths': galleryPaths,
      'brand': brand,
      'dialColor': dialColor,
      'strapMaterial': strapMaterial,
      'waterResistant': waterResistant,
      'warranty': warranty,
      'stockQuantity': stockQuantity,
      'stock': stockQuantity,
      'isFeatured': isFeatured,
      'featured': isFeatured,
      'isTrending': isTrending,
      'trending': isTrending,
      'isActive': isActive,
      'variants': variants.map((variant) => variant.toMap()).toList(),
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
    List<String>? imageUrls,
    List<String>? imagePaths,
    String? brand,
    String? dialColor,
    String? strapMaterial,
    bool? waterResistant,
    String? warranty,
    int? stockQuantity,
    bool? isFeatured,
    bool? isTrending,
    bool? isActive,
    List<AdminWatchVariant>? variants,
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
      imageUrls: imageUrls ?? this.imageUrls,
      imagePaths: imagePaths ?? this.imagePaths,
      brand: brand ?? this.brand,
      dialColor: dialColor ?? this.dialColor,
      strapMaterial: strapMaterial ?? this.strapMaterial,
      waterResistant: waterResistant ?? this.waterResistant,
      warranty: warranty ?? this.warranty,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      isActive: isActive ?? this.isActive,
      variants: variants ?? this.variants,
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

  static int _toInt(dynamic value) {
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

  static bool _toBool(dynamic value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (['true', 'yes', '1', 'available'].contains(lower)) {
        return true;
      }
      if (['false', 'no', '0', 'none'].contains(lower)) {
        return false;
      }
    }
    if (value is num) {
      return value != 0;
    }
    return fallback;
  }

  static List<dynamic> _listFrom(dynamic value) {
    if (value is Iterable) {
      return value.toList(growable: false);
    }
    return const [];
  }

  static List<String> _imageUrlsFrom(dynamic value) {
    return _listFrom(value)
        .map((item) {
          if (item is String) {
            return item;
          }
          if (item is Map) {
            return (item['imageUrl'] ?? item['url'] ?? item['image'])
                    ?.toString() ??
                '';
          }
          return '';
        })
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _stringList(dynamic value) {
    return _listFrom(value)
        .map((item) => item?.toString() ?? '')
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _mergePrimaryString(String primary, List<String> values) {
    final seen = <String>{};
    final merged = <String>[];
    for (final value in [primary, ...values]) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) {
        continue;
      }
      seen.add(trimmed);
      merged.add(trimmed);
    }
    return merged;
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

class AdminWatchVariant {
  final String dialColor;
  final String strapMaterial;
  final int stockQuantity;

  const AdminWatchVariant({
    required this.dialColor,
    required this.strapMaterial,
    required this.stockQuantity,
  });

  String get label => '$dialColor / $strapMaterial';

  Map<String, dynamic> toMap() {
    return {
      'dialColor': dialColor,
      'strapMaterial': strapMaterial,
      'stockQuantity': stockQuantity,
    };
  }

  factory AdminWatchVariant.fromDynamic(dynamic value) {
    if (value is String) {
      final parts = value.split('/');
      return AdminWatchVariant(
        dialColor: parts.first.trim(),
        strapMaterial: parts.length > 1 ? parts[1].trim() : '',
        stockQuantity: 0,
      );
    }

    final data = value is Map
        ? value.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    return AdminWatchVariant(
      dialColor:
          data['dialColor']?.toString() ?? data['color']?.toString() ?? '',
      strapMaterial:
          data['strapMaterial']?.toString() ?? data['strap']?.toString() ?? '',
      stockQuantity: AdminProduct._toInt(
        data['stockQuantity'] ?? data['stock'] ?? data['quantity'],
      ),
    );
  }
}
