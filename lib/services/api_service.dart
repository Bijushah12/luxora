import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/watch_model.dart';
import 'unsplash_service.dart';
import 'watch_content_service.dart';

class ApiService {
  static const String baseUrl = "https://fakestoreapi.com/products";

  static final List<String> categories = [
    "Men",
    "Women",
    "Luxury",
    "Sports",
    "Smart",
  ];

  static final List<String> brands = [
    "Rolex",
    "Omega",
    "Tag Heuer",
    "Casio",
    "Fossil",
  ];

  static Future<List<Watch>> getWatches() async {
    final firestoreWatches = await _getFirestoreWatches();
    if (firestoreWatches.isNotEmpty) {
      return firestoreWatches;
    }

    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final random = Random();

        /// 🔥 CATEGORY-WISE IMAGES FETCH
        Map<String, List<String>> categoryImages = {};

        for (String category in categories) {
          categoryImages[category] =
              await UnsplashService.fetchImagesByCategory(category);
        }

        List<Watch> watches = [];

        for (int i = 0; i < data.length; i++) {
          final item = data[i];
          final category = categories[i % categories.length];
          final images = categoryImages[category] ?? [];
          final image = (images.isNotEmpty)
              ? images[random.nextInt(images.length)]
              : "https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?w=400";
          final brand = brands[random.nextInt(brands.length)];
          final price = (random.nextDouble() * 15000 + 5000);
          final name = WatchContentService.generatedName(
            brand: brand,
            category: category,
            index: i,
          );

          watches.add(
            Watch(
              id: item['id'].toString(),
              name: name,
              brand: brand,
              price: price,
              description: WatchContentService.generatedDescription(
                name: name,
                brand: brand,
                category: category,
              ),
              category: category,
              image: image,
            ),
          );
        }

        return watches;
      } else {
        throw Exception("Server error");
      }
    } catch (_) {
      return [];
    }
  }

  static Future<List<Watch>> _getFirestoreWatches() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      return snapshot.docs
          .where((doc) => doc.data()['isActive'] != false)
          .map((doc) {
            final data = doc.data();
            final name =
                data['name'] as String? ?? data['title'] as String? ?? '';
            final brand = data['brand'] as String? ?? 'Luxora';
            final category = data['category'] as String? ?? 'Men';
            return Watch(
              id: doc.id,
              name: name,
              brand: brand,
              price: _toDouble(data['price']),
              image:
                  data['imageUrl'] as String? ?? data['image'] as String? ?? '',
              description: WatchContentService.descriptionFromRaw(
                rawDescription: data['description'] as String? ?? '',
                name: name,
                brand: brand,
                category: category,
              ),
              category: category,
            );
          })
          .where((watch) => watch.name.trim().isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return [];
    }
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
}
