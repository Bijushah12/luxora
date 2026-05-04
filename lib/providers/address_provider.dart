import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_address.dart';

class AddressProvider extends ChangeNotifier {
  static const String _storageKey = 'luxora_addresses';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  StreamSubscription<User?>? _authSubscription;

  final List<AppAddress> _addresses = [];
  bool _isLoaded = false;
  bool _disposed = false;

  AddressProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance {
    _authSubscription = _auth.authStateChanges().listen(_loadAddressesForUser);
    _loadAddressesForUser(_auth.currentUser);
  }

  bool get isLoaded => _isLoaded;
  List<AppAddress> get addresses => List.unmodifiable(_addresses);

  CollectionReference<Map<String, dynamic>> get _addressesRef =>
      _firestore.collection('addresses');

  Future<void> loadAddresses() async {
    if (_isLoaded) return;
    await _loadAddressesForUser(_auth.currentUser);
  }

  Future<void> _loadAddressesForUser(User? user) async {
    _isLoaded = false;
    _safeNotify();
    _addresses.clear();

    if (user == null) {
      await _loadLocalAddresses();
      _isLoaded = true;
      _safeNotify();
      return;
    }

    try {
      final doc = await _addressesRef.doc(user.uid).get();
      final rawAddresses = doc.data()?['addresses'];

      if (rawAddresses is Iterable) {
        _addresses.addAll(
          rawAddresses
              .whereType<Map>()
              .map((item) => AppAddress.fromMap(_stringMap(item)))
              .where((address) => address.id.trim().isNotEmpty),
        );
      }
    } catch (error) {
      debugPrint('Error loading cloud addresses: $error');
      await _loadLocalAddresses();
    }

    _isLoaded = true;
    _safeNotify();
  }

  Future<void> _loadLocalAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _addresses
          ..clear()
          ..addAll(
            decoded.map((item) => AppAddress.fromMap(_stringMap(item as Map))),
          );
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }
  }

  Future<void> addAddress(AppAddress address) async {
    final shouldBeDefault = _addresses.isEmpty || address.isDefault;
    final next = address.copyWith(isDefault: shouldBeDefault);

    if (next.isDefault) {
      _clearDefaultAddress();
    }

    _addresses.insert(0, next);
    await _saveAddresses();
    _safeNotify();
  }

  Future<void> updateAddress(AppAddress address) async {
    final index = _addresses.indexWhere((item) => item.id == address.id);
    if (index == -1) return;

    if (address.isDefault) {
      _clearDefaultAddress();
    }

    _addresses[index] = address;
    _ensureDefaultAddress();
    await _saveAddresses();
    _safeNotify();
  }

  Future<void> removeAddress(String id) async {
    _addresses.removeWhere((address) => address.id == id);
    _ensureDefaultAddress();
    await _saveAddresses();
    _safeNotify();
  }

  Future<void> setDefaultAddress(String id) async {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }

    await _saveAddresses();
    _safeNotify();
  }

  void _clearDefaultAddress() {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: false);
    }
  }

  void _ensureDefaultAddress() {
    if (_addresses.isEmpty) return;

    final hasDefault = _addresses.any((address) => address.isDefault);
    if (!hasDefault) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _addresses.map((address) => address.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encoded);

    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      final defaultAddress = _defaultAddressMap();
      final data = {
        'userId': user.uid,
        'addresses': _addresses.map((address) => address.toMap()).toList(),
        'totalAddresses': _addresses.length,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (defaultAddress != null) {
        data['defaultAddress'] = defaultAddress;
      }
      await _addressesRef.doc(user.uid).set(data, SetOptions(merge: true));
    } catch (error) {
      debugPrint('Error saving cloud addresses: $error');
    }
  }

  Map<String, dynamic>? _defaultAddressMap() {
    for (final address in _addresses) {
      if (address.isDefault) {
        return address.toMap();
      }
    }
    return null;
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
