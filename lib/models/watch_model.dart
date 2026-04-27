class Watch {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String image;
  final String description;
  final String category;

  const Watch({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
  });

  // 🔥 JSON → Model
  factory Watch.fromJson(Map<String, dynamic> json) {
    return Watch(
      id: json['id'].toString(),
      name: json['name'] ?? json['title'] ?? '',
      brand: json['brand'] ?? 'Unknown',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'] ?? 0.0,
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
    );
  }

  // 🔥 Model → JSON (useful for cart / storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'image': image,
      'description': description,
      'category': category,
    };
  }

  // 🔥 Copy (very useful in cart updates)
  Watch copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    String? image,
    String? description,
    String? category,
  }) {
    return Watch(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }
}