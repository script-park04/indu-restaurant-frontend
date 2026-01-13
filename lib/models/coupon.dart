class Coupon {
  final String id;
  final String code;
  final String discountType; // 'flat' or 'percentage'
  final double discountValue;
  final double minOrderAmount;
  final DateTime expiryDate;
  final int usageLimit;
  final int usageCount;
  final bool isFirstOrderOnly;
  final bool isActive;

  Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.expiryDate,
    required this.usageLimit,
    required this.usageCount,
    required this.isFirstOrderOnly,
    required this.isActive,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      usageLimit: json['usage_limit'] as int? ?? 1,
      usageCount: json['usage_count'] as int? ?? 0,
      isFirstOrderOnly: json['is_first_order_only'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_order_amount': minOrderAmount,
      'expiry_date': expiryDate.toIso8601String(),
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'is_first_order_only': isFirstOrderOnly,
      'is_active': isActive,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isLimitReached => usageCount >= usageLimit;

  double calculateDiscount(double subtotal) {
    if (discountType == 'percentage') {
      return (subtotal * discountValue) / 100;
    } else {
      return discountValue;
    }
  }
}
