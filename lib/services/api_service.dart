import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/watch_model.dart';
import 'unsplash_service.dart';

class ApiService {
  static const String baseUrl = "https://fakestoreapi.com/products";

  static final List<String> categories = [
    "Men",
    "Women",
    "Luxury",
    "Sports",
    "Smart"
  ];

  static final List<String> brands = [
    "Rolex",
    "Omega",
    "Tag Heuer",
    "Casio",
    "Fossil"
  ];

  static Future<List<Watch>> getWatches() async {
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

          watches.add(
            Watch(
              id: item['id'].toString(),
              name: item['title'] ?? "Luxury Watch",
              brand: brand,
              price: price,
              description: item['description'] ?? "",
              category: category,
              image: image,
            ),
          );
        }

        return watches;
      } else {
        throw Exception("Server error");
      }
    } catch (e) {
      print("API Error: $e");

      return [];
    }
  }
}