import '../config/supabase_config.dart';
import '../models/coupon.dart';
import 'auth_service.dart';

class CouponService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();

  Future<Coupon?> validateCoupon(String code, double orderTotal) async {
    try {
      final response = await _supabase
          .from('coupons')
          .select()
          .eq('code', code.toUpperCase())
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        throw Exception('Invalid coupon code');
      }

      final coupon = Coupon.fromJson(response);

      // Check Expiry
      if (coupon.isExpired) {
        throw Exception('Coupon has expired');
      }

      // Check Usage Limit
      if (coupon.isLimitReached) {
        throw Exception('Coupon usage limit reached');
      }

      // Check Min Order Amount
      if (orderTotal < coupon.minOrderAmount) {
        throw Exception('Minimum order amount of ₹${coupon.minOrderAmount.toStringAsFixed(0)} required');
      }

      // Check First Order Only
      if (coupon.isFirstOrderOnly) {
        final profile = await _authService.getUserProfile();
        if (profile != null && profile.totalOrders > 0) {
          throw Exception('This coupon is only for your first order');
        }
      }

      return coupon;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementUsage(String couponId) async {
    try {
      // Use rpc for atomic increment to avoid race conditions
      await _supabase.rpc('increment_coupon_usage', params: {'coupon_id': couponId});
    } catch (e) {
      // Fallback to manual update if RPC is not defined yet
      final response = await _supabase
          .from('coupons')
          .select('usage_count')
          .eq('id', couponId)
          .single();
      
      final currentUsage = response['usage_count'] as int;
      await _supabase
          .from('coupons')
          .update({'usage_count': currentUsage + 1})
          .eq('id', couponId);
    }
  }
}
