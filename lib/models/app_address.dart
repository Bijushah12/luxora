class AppAddress {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String addressLine;
  final bool isDefault;

  const AppAddress({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.isDefault,
  });

  AppAddress copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? addressLine,
    bool? isDefault,
  }) {
    return AppAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine: addressLine ?? this.addressLine,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'addressLine': addressLine,
      'isDefault': isDefault,
    };
  }

  factory AppAddress.fromMap(Map<String, dynamic> map) {
    return AppAddress(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? 'Home',
      fullName: map['fullName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      addressLine: map['addressLine'] as String? ?? '',
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }
}
