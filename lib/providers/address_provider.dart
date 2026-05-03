import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_address.dart';

class AddressProvider extends ChangeNotifier {
  static const String _storageKey = 'luxora_addresses';

  final List<AppAddress> _addresses = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<AppAddress> get addresses => List.unmodifiable(_addresses);

  Future<void> loadAddresses() async {
    if (_isLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _addresses
          ..clear()
          ..addAll(
            decoded.map(
              (item) => AppAddress.fromMap(item as Map<String, dynamic>),
            ),
          );
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addAddress(AppAddress address) async {
    final shouldBeDefault = _addresses.isEmpty || address.isDefault;
    final next = address.copyWith(isDefault: shouldBeDefault);

    if (next.isDefault) {
      _clearDefaultAddress();
    }

    _addresses.insert(0, next);
    await _saveAddresses();
    notifyListeners();
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
    notifyListeners();
  }

  Future<void> removeAddress(String id) async {
    _addresses.removeWhere((address) => address.id == id);
    _ensureDefaultAddress();
    await _saveAddresses();
    notifyListeners();
  }

  Future<void> setDefaultAddress(String id) async {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }

    await _saveAddresses();
    notifyListeners();
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
  }
}
