import '../config/supabase_config.dart';
import '../models/address.dart';
import '../services/auth_service.dart';

class LocationService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();

  // Get user addresses
  Future<List<Address>> getUserAddresses() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Address.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add address
  Future<Address> addAddress({
    required String label,
    required String addressLine,
    String? landmark,
    required String city,
    required String state,
    required String pincode,
    bool isDefault = false,
  }) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // If setting as default, unset other defaults
      if (isDefault) {
        await _supabase
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', userId);
      }

      final response = await _supabase.from('addresses').insert({
        'user_id': userId,
        'label': label,
        'address_line': addressLine,
        'landmark': landmark,
        'city': city,
        'state': state,
        'pincode': pincode,
        'is_default': isDefault,
      }).select().single();

      return Address.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update address
  Future<void> updateAddress(String addressId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('addresses')
          .update(updates)
          .eq('id', addressId);
    } catch (e) {
      rethrow;
    }
  }

  // Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      await _supabase
          .from('addresses')
          .delete()
          .eq('id', addressId);
    } catch (e) {
      rethrow;
    }
  }

  // Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Unset all defaults
      await _supabase
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', userId);

      // Set new default
      await _supabase
          .from('addresses')
          .update({'is_default': true})
          .eq('id', addressId);
    } catch (e) {
      rethrow;
    }
  }

  // Get default address
  Future<Address?> getDefaultAddress() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .eq('is_default', true)
          .maybeSingle();

      if (response == null) return null;
      return Address.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
