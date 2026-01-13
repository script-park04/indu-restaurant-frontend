import '../config/supabase_config.dart';
import '../models/app_config.dart';
import '../services/auth_service.dart';

class ConfigService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();

  AppConfigManager? _cachedConfig;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  // Get all app configuration
  Future<AppConfigManager> getAppConfig({bool forceRefresh = false}) async {
    try {
      // Return cached config if available and not expired
      if (!forceRefresh && 
          _cachedConfig != null && 
          _lastFetch != null && 
          DateTime.now().difference(_lastFetch!) < _cacheDuration) {
        return _cachedConfig!;
      }

      final response = await _supabase
          .from('app_config')
          .select();

      final configs = (response as List)
          .map((json) => AppConfig.fromJson(json))
          .toList();

      _cachedConfig = AppConfigManager(configs);
      _lastFetch = DateTime.now();

      return _cachedConfig!;
    } catch (e) {
      // Return default config if fetch fails
      return AppConfigManager([]);
    }
  }

  // Update a specific configuration value (admin only)
  Future<void> updateConfig(String key, String value) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      await _supabase
          .from('app_config')
          .update({
            'config_value': value,
            'updated_at': DateTime.now().toIso8601String(),
            'updated_by': userId,
          })
          .eq('config_key', key);

      // Clear cache to force refresh
      _cachedConfig = null;
    } catch (e) {
      rethrow;
    }
  }

  // Update discount configuration
  Future<void> updateDiscountConfig({
    double? firstOrderPercent,
    double? secondOrderPercent,
    double? subsequentOrderPercent,
    double? secondOrderMinAmount,
  }) async {
    try {
      if (firstOrderPercent != null) {
        await updateConfig('first_order_discount_percent', firstOrderPercent.toString());
      }
      if (secondOrderPercent != null) {
        await updateConfig('second_order_discount_percent', secondOrderPercent.toString());
      }
      if (subsequentOrderPercent != null) {
        await updateConfig('subsequent_order_discount_percent', subsequentOrderPercent.toString());
      }
      if (secondOrderMinAmount != null) {
        await updateConfig('second_order_min_amount', secondOrderMinAmount.toString());
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update delivery configuration
  Future<void> updateDeliveryConfig({
    double? deliveryCharge,
    double? freeDeliveryMinAmount,
  }) async {
    try {
      if (deliveryCharge != null) {
        await updateConfig('delivery_charge', deliveryCharge.toString());
      }
      if (freeDeliveryMinAmount != null) {
        await updateConfig('free_delivery_min_amount', freeDeliveryMinAmount.toString());
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update operating hours
  Future<void> updateOperatingHours({
    required String startTime,
    required String endTime,
  }) async {
    try {
      await updateConfig('operating_hours_start', startTime);
      await updateConfig('operating_hours_end', endTime);
    } catch (e) {
      rethrow;
    }
  }

  // Check if current time is within operating hours
  Future<bool> isWithinOperatingHours() async {
    try {
      final config = await getAppConfig();
      final now = DateTime.now();
      
      final startParts = config.operatingHoursStart.split(':');
      final endParts = config.operatingHoursEnd.split(':');
      
      final startTime = DateTime(
        now.year, now.month, now.day,
        int.parse(startParts[0]), int.parse(startParts[1]),
      );
      
      final endTime = DateTime(
        now.year, now.month, now.day,
        int.parse(endParts[0]), int.parse(endParts[1]),
      );
      
      return now.isAfter(startTime) && now.isBefore(endTime);
    } catch (e) {
      // Default to allowing orders if check fails
      return true;
    }
  }

  // Get next opening time
  Future<DateTime?> getNextOpeningTime() async {
    try {
      final config = await getAppConfig();
      final now = DateTime.now();
      
      final startParts = config.operatingHoursStart.split(':');
      
      var nextOpening = DateTime(
        now.year, now.month, now.day,
        int.parse(startParts[0]), int.parse(startParts[1]),
      );
      
      // If opening time has passed today, set to tomorrow
      if (nextOpening.isBefore(now)) {
        nextOpening = nextOpening.add(const Duration(days: 1));
      }
      
      return nextOpening;
    } catch (e) {
      return null;
    }
  }

  // Update loyalty configuration
  Future<void> updateLoyaltyConfig({
    double? pointsPerRupee,
    int? waitingPeriodHours,
    double? minRedemption,
    double? maxRedemption,
    double? firstOrderBonus,
  }) async {
    try {
      if (pointsPerRupee != null) {
        await updateConfig('loyalty_points_per_rupee', pointsPerRupee.toString());
      }
      if (waitingPeriodHours != null) {
        await updateConfig('loyalty_waiting_period_hours', waitingPeriodHours.toString());
      }
      if (minRedemption != null) {
        await updateConfig('min_loyalty_redemption', minRedemption.toString());
      }
      if (maxRedemption != null) {
        await updateConfig('max_loyalty_redemption', maxRedemption.toString());
      }
      if (firstOrderBonus != null) {
        await updateConfig('first_order_loyalty_bonus', firstOrderBonus.toString());
      }
    } catch (e) {
      rethrow;
    }
  }
}
