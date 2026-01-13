import '../config/supabase_config.dart';
import '../services/auth_service.dart';
import '../services/config_service.dart';

class LoyaltyService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();
  final _configService = ConfigService();

  // Calculate loyalty points for an order amount
  Future<double> calculatePointsForOrder(double amount) async {
    try {
      final config = await _configService.getAppConfig();
      return amount * config.loyaltyPointsPerRupee;
    } catch (e) {
      return amount; // Default: 1 point per rupee
    }
  }

  // Get available loyalty balance (only points older than waiting period)
  Future<double> getAvailableLoyaltyBalance() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return 0.0;

      final profile = await _authService.getUserProfile();
      if (profile == null) return 0.0;

      // Check if first order date exists and waiting period has passed
      if (profile.firstOrderDate == null) return 0.0;

      final config = await _configService.getAppConfig();
      final waitingPeriod = Duration(hours: config.loyaltyWaitingPeriodHours);
      final availableDate = profile.firstOrderDate!.add(waitingPeriod);

      if (DateTime.now().isBefore(availableDate)) {
        return 0.0; // Waiting period not passed
      }

      return profile.loyaltyPoints;
    } catch (e) {
      return 0.0;
    }
  }

  // Check if points can be redeemed (within min-max range)
  Future<bool> canRedeemPoints(double points) async {
    try {
      final config = await _configService.getAppConfig();
      final available = await getAvailableLoyaltyBalance();

      if (available < points) return false;
      if (points < config.minLoyaltyRedemption) return false;
      if (points > config.maxLoyaltyRedemption) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get time remaining until loyalty points are available
  Future<Duration?> getTimeUntilAvailable() async {
    try {
      final profile = await _authService.getUserProfile();
      if (profile == null || profile.firstOrderDate == null) return null;

      final config = await _configService.getAppConfig();
      final waitingPeriod = Duration(hours: config.loyaltyWaitingPeriodHours);
      final availableDate = profile.firstOrderDate!.add(waitingPeriod);

      if (DateTime.now().isAfter(availableDate)) {
        return Duration.zero; // Already available
      }

      return availableDate.difference(DateTime.now());
    } catch (e) {
      return null;
    }
  }

  // Redeem loyalty points for an order
  Future<void> redeemPoints(String orderId, double points) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Verify points can be redeemed
      if (!await canRedeemPoints(points)) {
        throw Exception('Cannot redeem these points');
      }

      // Update user profile
      await _supabase.rpc('redeem_loyalty_points', params: {
        'user_id': userId,
        'points': points,
        'order_id': orderId,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get loyalty transaction history
  Future<List<Map<String, dynamic>>> getLoyaltyHistory() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return [];

      // Get orders with loyalty points
      final response = await _supabase
          .from('orders')
          .select('id, created_at, loyalty_points_earned, loyalty_points_used, final_amount')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((order) {
        return {
          'date': DateTime.parse(order['created_at'] as String),
          'type': order['loyalty_points_earned'] > 0 ? 'earned' : 'redeemed',
          'points': order['loyalty_points_earned'] > 0 
              ? order['loyalty_points_earned'] 
              : order['loyalty_points_used'],
          'order_id': order['id'],
          'order_amount': order['final_amount'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Award first order bonus (called by order service)
  Future<void> awardFirstOrderBonus(String userId) async {
    try {
      final config = await _configService.getAppConfig();
      final bonus = config.firstOrderLoyaltyBonus;

      await _supabase
          .from('profiles')
          .update({
            'loyalty_points': bonus,
            'loyalty_points_earned': bonus,
          })
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Get loyalty points summary
  Future<Map<String, dynamic>> getLoyaltySummary() async {
    try {
      final profile = await _authService.getUserProfile();
      if (profile == null) {
        return {
          'total_points': 0.0,
          'available_points': 0.0,
          'redeemed_points': 0.0,
          'is_available': false,
          'time_until_available': null,
        };
      }

      final availablePoints = await getAvailableLoyaltyBalance();
      final timeUntilAvailable = await getTimeUntilAvailable();

      return {
        'total_points': profile.loyaltyPoints,
        'available_points': availablePoints,
        'redeemed_points': profile.loyaltyPointsRedeemed,
        'is_available': availablePoints > 0,
        'time_until_available': timeUntilAvailable,
      };
    } catch (e) {
      return {
        'total_points': 0.0,
        'available_points': 0.0,
        'redeemed_points': 0.0,
        'is_available': false,
        'time_until_available': null,
      };
    }
  }
}
