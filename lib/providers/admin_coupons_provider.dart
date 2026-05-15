import 'package:flutter/material.dart';

import '../models/admin_coupon.dart';
import '../services/admin_firestore_service.dart';

class AdminCouponsProvider extends ChangeNotifier {
  final AdminFirestoreService _service;

  bool _isSaving = false;
  final Set<String> _deletingCouponIds = {};
  String? _errorMessage;
  String? _successMessage;

  AdminCouponsProvider({AdminFirestoreService? service})
    : _service = service ?? AdminFirestoreService();

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Stream<List<AdminCoupon>> couponsStream() => _service.couponsStream();

  bool isDeleting(String couponId) => _deletingCouponIds.contains(couponId);

  Future<bool> save(AdminCoupon coupon) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.saveCoupon(coupon);
      _successMessage = coupon.id.isEmpty
          ? 'Coupon created successfully.'
          : 'Coupon updated successfully.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to save coupon. $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete(String couponId) async {
    _deletingCouponIds.add(couponId);
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.deleteCoupon(couponId);
      _successMessage = 'Coupon deleted successfully.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to delete coupon. $error';
      return false;
    } finally {
      _deletingCouponIds.remove(couponId);
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
