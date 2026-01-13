import '../config/supabase_config.dart';
import '../models/reward.dart';
import '../services/auth_service.dart';

class RewardsService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();

  // Get user rewards
  Future<List<Reward>> getUserRewards({bool onlyValid = false}) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      var query = _supabase
          .from('rewards')
          .select()
          .eq('user_id', userId);

      if (onlyValid) {
        query = query.eq('is_used', false);
      }

      final response = await query.order('created_at', ascending: false);

      final rewards = (response as List)
          .map((json) => Reward.fromJson(json))
          .toList();

      // Filter out expired rewards if only valid
      if (onlyValid) {
        return rewards.where((r) => r.isValid).toList();
      }

      return rewards;
    } catch (e) {
      rethrow;
    }
  }

  // Get total available rewards amount
  Future<double> getTotalRewardsAmount() async {
    try {
      final rewards = await getUserRewards(onlyValid: true);
      return rewards.fold<double>(0.0, (sum, reward) => sum + reward.amount);
    } catch (e) {
      return 0.0;
    }
  }

  // Apply reward to order
  Future<void> useReward(String rewardId) async {
    try {
      await _supabase
          .from('rewards')
          .update({'is_used': true})
          .eq('id', rewardId);
    } catch (e) {
      rethrow;
    }
  }

  // Create referral reward
  Future<void> createReferralReward({
    required String referrerId,
    required String referredId,
    double amount = 50.0,
  }) async {
    try {
      // Create reward for referrer
      await _supabase.from('rewards').insert({
        'user_id': referrerId,
        'reward_type': 'referral',
        'amount': amount,
        'description': 'Referral bonus for inviting a friend',
        'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });

      // Create reward for referred user
      await _supabase.from('rewards').insert({
        'user_id': referredId,
        'reward_type': 'referral',
        'amount': amount / 2, // Half for the new user
        'description': 'Welcome bonus for joining via referral',
        'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });

      // Mark referral as rewarded
      await _supabase.from('referrals').insert({
        'referrer_id': referrerId,
        'referred_id': referredId,
        'reward_given': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get referral code
  Future<String?> getReferralCode() async {
    try {
      final profile = await _authService.getUserProfile();
      return profile?.referralCode;
    } catch (e) {
      return null;
    }
  }

  // Get referral stats
  Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('referrals')
          .select()
          .eq('referrer_id', userId);

      final totalReferrals = (response as List).length;
      final rewardedReferrals = response.where((r) => r['reward_given'] == true).length;

      return {
        'total_referrals': totalReferrals,
        'rewarded_referrals': rewardedReferrals,
      };
    } catch (e) {
      return {
        'total_referrals': 0,
        'rewarded_referrals': 0,
      };
    }
  }

  // Validate and apply referral code
  Future<bool> applyReferralCode(String code) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return false;

      // Find user with this referral code
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('referral_code', code)
          .maybeSingle();

      if (response == null) return false;

      final referrerId = response['id'] as String;
      
      // Can't refer yourself
      if (referrerId == userId) return false;

      // Update current user's profile
      await _supabase
          .from('profiles')
          .update({'referred_by': referrerId})
          .eq('id', userId);

      // Create referral rewards
      await createReferralReward(
        referrerId: referrerId,
        referredId: userId,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

}
