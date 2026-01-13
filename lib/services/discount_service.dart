import '../config/supabase_config.dart';
import '../models/special_discount.dart';
import '../services/config_service.dart';

class DiscountService {
  final _supabase = SupabaseConfig.client;
  final _configService = ConfigService();

  // Calculate first order discount (10%)
  Future<double> calculateFirstOrderDiscount(double amount) async {
    try {
      final config = await _configService.getAppConfig();
      return amount * (config.firstOrderDiscountPercent / 100);
    } catch (e) {
      return amount * 0.10; // Default 10%
    }
  }

  // Calculate second order discount (10% if order >= 500)
  Future<double> calculateSecondOrderDiscount(double amount) async {
    try {
      final config = await _configService.getAppConfig();
      
      if (amount >= config.secondOrderMinAmount) {
        return amount * (config.secondOrderDiscountPercent / 100);
      }
      
      return 0.0;
    } catch (e) {
      return amount >= 500 ? amount * 0.10 : 0.0; // Default
    }
  }

  // Calculate subsequent order discount (5% from 3rd order onwards)
  Future<double> calculateSubsequentOrderDiscount(double amount) async {
    try {
      final config = await _configService.getAppConfig();
      return amount * (config.subsequentOrderDiscountPercent / 100);
    } catch (e) {
      return amount * 0.05; // Default 5%
    }
  }

  // Get applicable discount based on order count and amount
  Future<Map<String, dynamic>> getApplicableDiscount(int orderCount, double amount) async {
    try {
      double discountAmount = 0.0;
      String discountType = 'none';
      String description = '';

      if (orderCount == 0) {
        // First order
        discountAmount = await calculateFirstOrderDiscount(amount);
        discountType = 'first_order';
        description = 'First order discount';
      } else if (orderCount == 1) {
        // Second order
        discountAmount = await calculateSecondOrderDiscount(amount);
        if (discountAmount > 0) {
          discountType = 'second_order';
          description = 'Second order discount';
        }
      } else {
        // Third order onwards
        discountAmount = await calculateSubsequentOrderDiscount(amount);
        discountType = 'subsequent_order';
        description = 'Loyal customer discount';
      }

      // Check for special discounts
      final specialDiscounts = await getActiveSpecialDiscounts();
      for (var special in specialDiscounts) {
        final specialAmount = amount * (special.discountPercent / 100);
        if (specialAmount > discountAmount) {
          discountAmount = specialAmount;
          discountType = 'special';
          description = special.name;
        }
      }

      return {
        'amount': discountAmount,
        'type': discountType,
        'description': description,
        'percent': discountAmount > 0 ? (discountAmount / amount * 100) : 0.0,
      };
    } catch (e) {
      return {
        'amount': 0.0,
        'type': 'none',
        'description': '',
        'percent': 0.0,
      };
    }
  }

  // Get active special discounts (weekly, match day, etc.)
  Future<List<SpecialDiscount>> getActiveSpecialDiscounts() async {
    try {
      final now = DateTime.now();
      
      final response = await _supabase
          .from('special_discounts')
          .select()
          .eq('is_active', true)
          .lte('start_date', now.toIso8601String())
          .gte('end_date', now.toIso8601String());

      final discounts = (response as List)
          .map((json) => SpecialDiscount.fromJson(json))
          .where((discount) => discount.isCurrentlyActive)
          .toList();

      return discounts;
    } catch (e) {
      return [];
    }
  }

  // Create special discount (admin only)
  Future<void> createSpecialDiscount({
    required String name,
    String? description,
    required double discountPercent,
    required DateTime startDate,
    required DateTime endDate,
    List<int>? applicableDays,
  }) async {
    try {
      await _supabase.from('special_discounts').insert({
        'name': name,
        'description': description,
        'discount_percent': discountPercent,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'applicable_days': applicableDays ?? [0, 1, 2, 3, 4, 5, 6],
        'is_active': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update special discount (admin only)
  Future<void> updateSpecialDiscount(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('special_discounts')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Delete special discount (admin only)
  Future<void> deleteSpecialDiscount(String id) async {
    try {
      await _supabase
          .from('special_discounts')
          .delete()
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Get all special discounts (admin only)
  Future<List<SpecialDiscount>> getAllSpecialDiscounts() async {
    try {
      final response = await _supabase
          .from('special_discounts')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SpecialDiscount.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Apply best discount from multiple options
  double applyBestDiscount(double amount, List<double> discounts) {
    if (discounts.isEmpty) return 0.0;
    return discounts.reduce((a, b) => a > b ? a : b);
  }
}
