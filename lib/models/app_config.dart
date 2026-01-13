class AppConfig {
  final String id;
  final String configKey;
  final String configValue;
  final String? description;
  final DateTime updatedAt;
  final String? updatedBy;

  AppConfig({
    required this.id,
    required this.configKey,
    required this.configValue,
    this.description,
    required this.updatedAt,
    this.updatedBy,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      id: json['id'] as String,
      configKey: json['config_key'] as String,
      configValue: json['config_value'] as String,
      description: json['description'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      updatedBy: json['updated_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'config_key': configKey,
      'config_value': configValue,
      'description': description,
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  // Helper getters for typed values
  double get doubleValue => double.tryParse(configValue) ?? 0.0;
  int get intValue => int.tryParse(configValue) ?? 0;
  bool get boolValue => configValue.toLowerCase() == 'true';
}

// Helper class to manage all app configurations
class AppConfigManager {
  final Map<String, AppConfig> _configs = {};

  AppConfigManager(List<AppConfig> configs) {
    for (var config in configs) {
      _configs[config.configKey] = config;
    }
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _configs[key]?.doubleValue ?? defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _configs[key]?.intValue ?? defaultValue;
  }

  String getString(String key, {String defaultValue = ''}) {
    return _configs[key]?.configValue ?? defaultValue;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _configs[key]?.boolValue ?? defaultValue;
  }

  // Specific getters for known config keys
  double get firstOrderDiscountPercent => getDouble('first_order_discount_percent', defaultValue: 10.0);
  double get secondOrderDiscountPercent => getDouble('second_order_discount_percent', defaultValue: 10.0);
  double get subsequentOrderDiscountPercent => getDouble('subsequent_order_discount_percent', defaultValue: 5.0);
  double get secondOrderMinAmount => getDouble('second_order_min_amount', defaultValue: 500.0);
  double get freeDeliveryMinAmount => getDouble('free_delivery_min_amount', defaultValue: 500.0);
  double get deliveryCharge => getDouble('delivery_charge', defaultValue: 20.0);
  double get firstOrderLoyaltyBonus => getDouble('first_order_loyalty_bonus', defaultValue: 50.0);
  double get loyaltyPointsPerRupee => getDouble('loyalty_points_per_rupee', defaultValue: 1.0);
  int get loyaltyWaitingPeriodHours => getInt('loyalty_waiting_period_hours', defaultValue: 72);
  double get minLoyaltyRedemption => getDouble('min_loyalty_redemption', defaultValue: 250.0);
  double get maxLoyaltyRedemption => getDouble('max_loyalty_redemption', defaultValue: 500.0);
  double get referralReward => getDouble('referral_reward', defaultValue: 50.0);
  String get operatingHoursStart => getString('operating_hours_start', defaultValue: '14:00');
  String get operatingHoursEnd => getString('operating_hours_end', defaultValue: '23:30');
}
