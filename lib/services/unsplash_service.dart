import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class UnsplashService {
  static const String apiKey = "nbmj_CZmjUJy19i0JHrLL76GyhQRdAzruPUBAoekK0Q";

  static Future<List<String>> fetchImagesByCategory(String category) async {
    String query = "watch";

    switch (category.toLowerCase()) {
      case "men":
        query = "men wrist watch";
        break;
      case "women":
        query = "women watch elegant";
        break;
      case "luxury":
        query = "rolex luxury watch";
        break;
      case "sports":
        query = "sports watch";
        break;
      case "smart":
        query = "smartwatch apple watch";
        break;
      case "banner":
        query = "luxury watch banner";
        break;
    }

    final random = Random();

    final url =
"https://api.unsplash.com/search/photos?query=$query&per_page=20&page=${random.nextInt(5)+1}&client_id=$apiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['results'] as List)
          .map((img) => img['urls']['regular'] as String)
          .toList();
    } else {
      throw Exception("Unsplash error");
    }
  }
}
