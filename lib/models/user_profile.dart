class UserProfile {
  final String id;
  final String? fullName;
  final String? phone;
  final bool phoneVerified;
  final double signupBonus;
  final int totalOrders;
  final String? referralCode;
  final String? referredBy;
  final String role;
  final double loyaltyPoints;
  final double loyaltyPointsEarned;
  final double loyaltyPointsRedeemed;
  final bool isFirstOrder;
  final DateTime? firstOrderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.fullName,
    this.phone,
    this.phoneVerified = false,
    this.signupBonus = 500.0,
    this.totalOrders = 0,
    this.referralCode,
    this.referredBy,
    this.role = 'customer',
    this.loyaltyPoints = 0.0,
    this.loyaltyPointsEarned = 0.0,
    this.loyaltyPointsRedeemed = 0.0,
    this.isFirstOrder = true,
    this.firstOrderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      signupBonus: (json['signup_bonus'] as num?)?.toDouble() ?? 500.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      referralCode: json['referral_code'] as String?,
      referredBy: json['referred_by'] as String?,
      role: json['role'] as String? ?? 'customer',
      loyaltyPoints: (json['loyalty_points'] as num?)?.toDouble() ?? 0.0,
      loyaltyPointsEarned: (json['loyalty_points_earned'] as num?)?.toDouble() ?? 0.0,
      loyaltyPointsRedeemed: (json['loyalty_points_redeemed'] as num?)?.toDouble() ?? 0.0,
      isFirstOrder: json['is_first_order'] as bool? ?? true,
      firstOrderDate: json['first_order_date'] != null ? DateTime.parse(json['first_order_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'phone_verified': phoneVerified,
      'signup_bonus': signupBonus,
      'total_orders': totalOrders,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'role': role,
      'loyalty_points': loyaltyPoints,
      'loyalty_points_earned': loyaltyPointsEarned,
      'loyalty_points_redeemed': loyaltyPointsRedeemed,
      'is_first_order': isFirstOrder,
      'first_order_date': firstOrderDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? phone,
    bool? phoneVerified,
    double? signupBonus,
    int? totalOrders,
    String? referralCode,
    String? referredBy,
    String? role,
    double? loyaltyPoints,
    double? loyaltyPointsEarned,
    double? loyaltyPointsRedeemed,
    bool? isFirstOrder,
    DateTime? firstOrderDate,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      signupBonus: signupBonus ?? this.signupBonus,
      totalOrders: totalOrders ?? this.totalOrders,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      role: role ?? this.role,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      loyaltyPointsRedeemed: loyaltyPointsRedeemed ?? this.loyaltyPointsRedeemed,
      isFirstOrder: isFirstOrder ?? this.isFirstOrder,
      firstOrderDate: firstOrderDate ?? this.firstOrderDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
