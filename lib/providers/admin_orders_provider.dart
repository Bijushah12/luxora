import 'package:flutter/material.dart';

import '../models/admin_order.dart';
import '../services/admin_firestore_service.dart';

class AdminOrdersProvider extends ChangeNotifier {
  final AdminFirestoreService _service;
  final Set<String> _updatingOrderIds = {};
  String? _errorMessage;
  String? _successMessage;

  AdminOrdersProvider({AdminFirestoreService? service})
    : _service = service ?? AdminFirestoreService();

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Stream<List<AdminOrder>> ordersStream() => _service.ordersStream();

  bool isUpdating(String orderId) => _updatingOrderIds.contains(orderId);

  Future<bool> updateStatus(String orderId, String status) async {
    _updatingOrderIds.add(orderId);
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.updateOrderStatus(orderId, status);
      _successMessage = 'Order status updated.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to update order status. $error';
      return false;
    } finally {
      _updatingOrderIds.remove(orderId);
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
