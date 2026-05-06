import 'package:flutter/material.dart';

import '../models/admin_storefront_settings.dart';
import '../services/admin_firestore_service.dart';

class AdminSettingsProvider extends ChangeNotifier {
  final AdminFirestoreService _service;

  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  AdminSettingsProvider({AdminFirestoreService? service})
    : _service = service ?? AdminFirestoreService();

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Stream<AdminStorefrontSettings> settingsStream() {
    return _service.storefrontSettingsStream();
  }

  Future<bool> save(AdminStorefrontSettings settings) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.saveStorefrontSettings(settings);
      _successMessage = 'Storefront settings updated.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to update settings. $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
