import 'package:flutter/foundation.dart';
import '../models/watch_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Watch> _wishlistItems = [];

  List<Watch> get wishlistItems => _wishlistItems;

  bool isFavorite(Watch watch) {
    return _wishlistItems.contains(watch);
  }

  void toggleWishlist(Watch watch) {
    if (isFavorite(watch)) {
      _wishlistItems.remove(watch);
    } else {
      _wishlistItems.add(watch);
    }
    notifyListeners();
  }

  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
