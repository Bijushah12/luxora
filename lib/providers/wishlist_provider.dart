import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/watch_model.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<User?>? _authSubscription;
  final List<Watch> _wishlistItems = [];
  bool _isLoading = false;
  bool _disposed = false;

  WishlistProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance {
    _authSubscription = _auth.authStateChanges().listen(_loadWishlistForUser);
    _loadWishlistForUser(_auth.currentUser);
  }

  List<Watch> get wishlistItems => List.unmodifiable(_wishlistItems);
  bool get isLoading => _isLoading;

  CollectionReference<Map<String, dynamic>> get _wishlists =>
      _firestore.collection('wishlists');

  bool isFavorite(Watch watch) {
    return _wishlistItems.any((item) => item.id == watch.id);
  }

  void toggleWishlist(Watch watch) {
    if (isFavorite(watch)) {
      _wishlistItems.removeWhere((item) => item.id == watch.id);
    } else {
      _wishlistItems.insert(0, watch);
    }
    _notifyAndSave();
  }

  void clearWishlist() {
    _wishlistItems.clear();
    _notifyAndSave();
  }

  Future<void> _loadWishlistForUser(User? user) async {
    _isLoading = true;
    _safeNotify();
    _wishlistItems.clear();

    if (user == null) {
      _isLoading = false;
      _safeNotify();
      return;
    }

    try {
      final doc = await _wishlists.doc(user.uid).get();
      final rawItems = doc.data()?['items'];

      if (rawItems is Iterable) {
        _wishlistItems.addAll(
          rawItems
              .whereType<Map>()
              .map((item) => Watch.fromJson(_stringMap(item)))
              .where((watch) => watch.id.trim().isNotEmpty),
        );
      }
    } catch (error) {
      debugPrint('Error loading wishlist: $error');
    }

    _isLoading = false;
    _safeNotify();
  }

  void _notifyAndSave() {
    _safeNotify();
    _saveWishlist();
  }

  Future<void> _saveWishlist() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _wishlists.doc(user.uid).set({
        'userId': user.uid,
        'items': _wishlistItems.map((watch) => watch.toJson()).toList(),
        'totalItems': _wishlistItems.length,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error) {
      debugPrint('Error saving wishlist: $error');
    }
  }

  Map<String, dynamic> _stringMap(Map<dynamic, dynamic> value) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}
