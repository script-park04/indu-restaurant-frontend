class Address {
  final String id;
  final String userId;
  final String label;
  final String addressLine;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;
  final DateTime createdAt;

  Address({
    required this.id,
    required this.userId,
    this.label = 'Home',
    required this.addressLine,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String? ?? 'Home',
      addressLine: json['address_line'] as String,
      landmark: json['landmark'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'address_line': addressLine,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullAddress {
    final parts = [
      addressLine,
      if (landmark != null) landmark,
      city,
      state,
      pincode,
    ];
    return parts.join(', ');
  }
}
