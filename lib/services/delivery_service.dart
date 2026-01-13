import '../config/supabase_config.dart';
import '../models/service_radius.dart';
import '../services/config_service.dart';

class DeliveryService {
  final _supabase = SupabaseConfig.client;
  final _configService = ConfigService();

  // Validate if pincode is serviceable
  Future<bool> validatePincode(String pincode) async {
    try {
      final response = await _supabase
          .from('service_radius')
          .select()
          .eq('pincode', pincode)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return false;

      final serviceArea = ServiceRadius.fromJson(response);
      return serviceArea.isWithinServiceRange;
    } catch (e) {
      return false;
    }
  }

  // Get distance for a pincode
  Future<double?> getDistanceForPincode(String pincode) async {
    try {
      final response = await _supabase
          .from('service_radius')
          .select()
          .eq('pincode', pincode)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;

      final serviceArea = ServiceRadius.fromJson(response);
      return serviceArea.distanceKm;
    } catch (e) {
      return null;
    }
  }

  // Calculate delivery charge based on order amount
  Future<double> calculateDeliveryCharge(double orderAmount) async {
    try {
      final config = await _configService.getAppConfig();
      
      if (orderAmount >= config.freeDeliveryMinAmount) {
        return 0.0; // Free delivery
      }
      
      return config.deliveryCharge;
    } catch (e) {
      // Default: ₹20 for orders below ₹500
      return orderAmount >= 500 ? 0.0 : 20.0;
    }
  }

  // Get all serviceable areas
  Future<List<ServiceRadius>> getServiceableAreas() async {
    try {
      final response = await _supabase
          .from('service_radius')
          .select()
          .eq('is_active', true)
          .order('city');

      return (response as List)
          .map((json) => ServiceRadius.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Add service area (admin only)
  Future<void> addServiceArea({
    required String pincode,
    required String city,
    String? area,
    required double distanceKm,
  }) async {
    try {
      await _supabase.from('service_radius').insert({
        'pincode': pincode,
        'city': city,
        'area': area,
        'distance_km': distanceKm,
        'is_active': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update service area (admin only)
  Future<void> updateServiceArea(String id, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await _supabase
          .from('service_radius')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Delete service area (admin only)
  Future<void> deleteServiceArea(String id) async {
    try {
      await _supabase
          .from('service_radius')
          .delete()
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Toggle service area active status (admin only)
  Future<void> toggleServiceArea(String id, bool isActive) async {
    try {
      await _supabase
          .from('service_radius')
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Get all service areas (admin only)
  Future<List<ServiceRadius>> getAllServiceAreas() async {
    try {
      final response = await _supabase
          .from('service_radius')
          .select()
          .order('city');

      return (response as List)
          .map((json) => ServiceRadius.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Check if address is serviceable
  Future<Map<String, dynamic>> checkServiceability(String pincode) async {
    try {
      final response = await _supabase
          .from('service_radius')
          .select()
          .eq('pincode', pincode)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        return {
          'is_serviceable': false,
          'message': 'Sorry, we don\'t deliver to this area yet.',
          'distance': null,
        };
      }

      final serviceArea = ServiceRadius.fromJson(response);
      
      if (!serviceArea.isWithinServiceRange) {
        return {
          'is_serviceable': false,
          'message': 'This area is outside our delivery range (3-6 km).',
          'distance': serviceArea.distanceKm,
        };
      }

      return {
        'is_serviceable': true,
        'message': 'Great! We deliver to your area.',
        'distance': serviceArea.distanceKm,
        'city': serviceArea.city,
        'area': serviceArea.area,
      };
    } catch (e) {
      return {
        'is_serviceable': false,
        'message': 'Unable to verify serviceability. Please try again.',
        'distance': null,
      };
    }
  }
}
