import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCoupon {
  final String id;
  final String code;
  final String title;
  final String discountType;
  final double discountValue;
  final double minOrderValue;
  final int maxUses;
  final int usedCount;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const AdminCoupon({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.maxUses,
    required this.usedCount,
    required this.isActive,
    this.expiresAt,
    this.createdAt,
  });

  bool get isExpired {
    final expiry = expiresAt;
    return expiry != null && expiry.isBefore(DateTime.now());
  }

  int get remainingUses {
    if (maxUses <= 0) {
      return 0;
    }
    return (maxUses - usedCount).clamp(0, maxUses);
  }

  String get displayDiscount {
    if (discountType == 'flat') {
      return 'Rs ${discountValue.toStringAsFixed(0)}';
    }
    return '${discountValue.toStringAsFixed(0)}%';
  }

  factory AdminCoupon.empty() {
    return const AdminCoupon(
      id: '',
      code: '',
      title: '',
      discountType: 'percentage',
      discountValue: 0,
      minOrderValue: 0,
      maxUses: 100,
      usedCount: 0,
      isActive: true,
    );
  }

  AdminCoupon copyWith({
    String? id,
    String? code,
    String? title,
    String? discountType,
    double? discountValue,
    double? minOrderValue,
    int? maxUses,
    int? usedCount,
    bool? isActive,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return AdminCoupon(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AdminCoupon.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return AdminCoupon(
      id: snapshot.id,
      code: _string(data['code']).toUpperCase(),
      title: _string(data['title']),
      discountType: _string(data['discountType']).trim().isEmpty
          ? 'percentage'
          : _string(data['discountType']),
      discountValue: _toDouble(data['discountValue'] ?? data['discount']),
      minOrderValue: _toDouble(data['minOrderValue']),
      maxUses: _toInt(data['maxUses']),
      usedCount: _toInt(data['usedCount']),
      isActive: data['isActive'] as bool? ?? true,
      expiresAt: _toDateTime(data['expiresAt']),
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code.trim().toUpperCase(),
      'title': title.trim(),
      'discountType': discountType,
      'discountValue': discountValue,
      'minOrderValue': minOrderValue,
      'maxUses': maxUses,
      'usedCount': usedCount,
      'isActive': isActive,
      'expiresAt': expiresAt == null ? null : Timestamp.fromDate(expiresAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

String _string(dynamic value) => value?.toString() ?? '';

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

double _toDouble(dynamic value) {
  if (value is int) {
    return value.toDouble();
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

DateTime? _toDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
