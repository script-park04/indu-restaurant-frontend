class Reward {
  final String id;
  final String userId;
  final String rewardType;
  final double amount;
  final String? description;
  final bool isUsed;
  final DateTime? expiresAt;
  final DateTime createdAt;

  Reward({
    required this.id,
    required this.userId,
    required this.rewardType,
    required this.amount,
    this.description,
    this.isUsed = false,
    this.expiresAt,
    required this.createdAt,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      rewardType: json['reward_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      isUsed: json['is_used'] as bool? ?? false,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reward_type': rewardType,
      'amount': amount,
      'description': description,
      'is_used': isUsed,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid => !isUsed && !isExpired;
}
