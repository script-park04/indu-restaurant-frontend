import '../config/supabase_config.dart';
import '../models/cart_item.dart';
import '../services/auth_service.dart';

class CartService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();

  // Get cart items for current user
  Future<List<CartItem>> getCartItems() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('cart_items')
          .select('*, menu_items(*)')
          .eq('user_id', userId)
          .order('created_at');

      return (response as List)
          .map((json) => CartItem.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add item to cart
  Future<void> addToCart({
    required String itemId,
    int quantity = 1,
    bool isHalfPlate = false,
  }) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Check if item already exists in cart
      final existing = await _supabase
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .eq('item_id', itemId)
          .eq('is_half_plate', isHalfPlate)
          .maybeSingle();

      if (existing != null) {
        // Update quantity
        await _supabase
            .from('cart_items')
            .update({
              'quantity': existing['quantity'] + quantity,
            })
            .eq('id', existing['id']);
      } else {
        // Insert new cart item
        await _supabase.from('cart_items').insert({
          'user_id': userId,
          'item_id': itemId,
          'quantity': quantity,
          'is_half_plate': isHalfPlate,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update cart item quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      await _supabase
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId);
    } catch (e) {
      rethrow;
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _supabase
          .from('cart_items')
          .delete()
          .eq('id', cartItemId);
    } catch (e) {
      rethrow;
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      await _supabase
          .from('cart_items')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Get cart total
  Future<double> getCartTotal() async {
    try {
      final items = await getCartItems();
      return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    } catch (e) {
      return 0.0;
    }
  }

  // Get cart item count
  Future<int> getCartItemCount() async {
    try {
      final items = await getCartItems();
      return items.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      return 0;
    }
  }
}
