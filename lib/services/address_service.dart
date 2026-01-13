import '../config/supabase_config.dart';
import '../models/address.dart';
import 'auth_service.dart';

class AddressService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();

  // Get current user addresses
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

  // Add new address
  Future<Address> addAddress(Address address) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // If this is the first address, make it default
      final existingAddresses = await getUserAddresses();
      final isFirst = existingAddresses.isEmpty;
      
      final Map<String, dynamic> data = {
        'user_id': userId,
        'label': address.label,
        'address_line': address.addressLine,
        'city': address.city,
        'state': address.state,
        'pincode': address.pincode,
        'landmark': address.landmark,
        'is_default': address.isDefault || isFirst,
      };

      // If setting as default, unset others first
      if (data['is_default'] == true && !isFirst) {
        await _supabase
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', userId);
      }

      final response = await _supabase
          .from('addresses')
          .insert(data)
          .select()
          .single();

      return Address.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update address
  Future<Address> updateAddress(Address address) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // If setting as default, unset others first
      if (address.isDefault) {
        await _supabase
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', userId);
      }

      final response = await _supabase
          .from('addresses')
          .update({
            'label': address.label,
            'address_line': address.addressLine,
            'city': address.city,
            'state': address.state,
            'pincode': address.pincode,
            'landmark': address.landmark,
            'is_default': address.isDefault,
          })
          .eq('id', address.id)
          .select()
          .single();

      return Address.fromJson(response);
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

  // Get address by ID
  Future<Address?> getAddressById(String addressId) async {
    try {
      final response = await _supabase
          .from('addresses')
          .select()
          .eq('id', addressId)
          .maybeSingle();

      if (response == null) return null;
      return Address.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
