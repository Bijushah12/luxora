import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/admin_coupon.dart';

class CouponsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  AdminCoupon? _selectedCoupon;
  String? _errorMessage;
  String? _successMessage;

  CouponsProvider({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  AdminCoupon? get selectedCoupon => _selectedCoupon;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  CollectionReference<Map<String, dynamic>> get _coupons =>
      _firestore.collection('coupons');

  Stream<List<AdminCoupon>> activeCouponsStream() {
    return _coupons.snapshots().map((snapshot) {
      final coupons = snapshot.docs
          .map(AdminCoupon.fromFirestore)
          .where(_isVisibleCoupon)
          .toList(growable: false);
      coupons.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return coupons;
    });
  }

  bool canUse(AdminCoupon coupon, double subtotal) {
    return _isVisibleCoupon(coupon) && subtotal >= coupon.minOrderValue;
  }

  double discountFor(double subtotal) {
    final coupon = _selectedCoupon;
    if (coupon == null || !canUse(coupon, subtotal)) {
      return 0;
    }

    if (coupon.discountType == 'flat') {
      return coupon.discountValue.clamp(0, subtotal).toDouble();
    }

    return (subtotal * (coupon.discountValue / 100))
        .clamp(0, subtotal)
        .toDouble();
  }

  bool applyCoupon(AdminCoupon coupon, double subtotal) {
    _errorMessage = null;
    _successMessage = null;

    if (!_isVisibleCoupon(coupon)) {
      _errorMessage = 'This coupon is no longer available.';
      notifyListeners();
      return false;
    }
    if (subtotal < coupon.minOrderValue) {
      _errorMessage =
          'Add items worth Rs ${(coupon.minOrderValue - subtotal).toStringAsFixed(0)} more to use ${coupon.code}.';
      notifyListeners();
      return false;
    }

    _selectedCoupon = coupon;
    _successMessage = '${coupon.code} applied successfully.';
    notifyListeners();
    return true;
  }

  bool applyCode(String code, List<AdminCoupon> coupons, double subtotal) {
    final normalized = code.trim().toUpperCase();
    final match = coupons
        .where((coupon) => coupon.code.toUpperCase() == normalized)
        .cast<AdminCoupon?>()
        .firstWhere((coupon) => coupon != null, orElse: () => null);

    if (match == null) {
      _errorMessage = 'Coupon code not found.';
      _successMessage = null;
      notifyListeners();
      return false;
    }

    return applyCoupon(match, subtotal);
  }

  void clearCoupon() {
    _selectedCoupon = null;
    _errorMessage = null;
    _successMessage = 'Coupon removed.';
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  bool _isVisibleCoupon(AdminCoupon coupon) {
    final hasUses = coupon.maxUses <= 0 || coupon.remainingUses > 0;
    return coupon.isActive && !coupon.isExpired && hasUses;
  }
}
