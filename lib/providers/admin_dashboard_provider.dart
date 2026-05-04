import 'package:flutter/material.dart';

import '../services/admin_firestore_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final AdminFirestoreService _service;

  AdminDashboardStats _stats = AdminDashboardStats.empty();
  bool _isLoading = false;
  String? _errorMessage;

  AdminDashboardProvider({AdminFirestoreService? service})
    : _service = service ?? AdminFirestoreService();

  AdminDashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _service.fetchDashboardStats();
    } catch (error) {
      _errorMessage = 'Unable to load dashboard. $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
