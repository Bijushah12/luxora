import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStorefrontSettings {
  final List<String> categories;
  final List<String> brands;
  final double globalDiscount;
  final List<String> bannerUrls;
  final DateTime? updatedAt;

  const AdminStorefrontSettings({
    required this.categories,
    required this.brands,
    required this.globalDiscount,
    required this.bannerUrls,
    this.updatedAt,
  });

  factory AdminStorefrontSettings.defaults() {
    return const AdminStorefrontSettings(
      categories: ['Men', 'Women', 'Luxury', 'Sports', 'Smart'],
      brands: ['Luxora', 'Rolex', 'Apple', 'Titan'],
      globalDiscount: 0,
      bannerUrls: [],
    );
  }

  factory AdminStorefrontSettings.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final fallback = AdminStorefrontSettings.defaults();

    return AdminStorefrontSettings(
      categories: _stringList(data['categories'], fallback.categories),
      brands: _stringList(data['brands'], fallback.brands),
      globalDiscount: _toDouble(data['globalDiscount']),
      bannerUrls: _stringList(data['bannerUrls'], const []),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categories': categories,
      'brands': brands,
      'globalDiscount': globalDiscount,
      'bannerUrls': bannerUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

List<String> _stringList(dynamic value, List<String> fallback) {
  if (value is! Iterable) {
    return fallback;
  }
  final items = value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList();
  return items.isEmpty ? fallback : items;
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
