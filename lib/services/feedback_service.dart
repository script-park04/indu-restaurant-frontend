import '../config/supabase_config.dart';
import '../models/feedback.dart';
import '../services/auth_service.dart';

class FeedbackService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();

  // Submit feedback for a menu item
  Future<void> submitFeedback({
    required String orderId,
    required String menuItemId,
    required int rating,
    String? comment,
  }) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Validate rating
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      // Check if order is delivered
      if (!await canSubmitFeedback(orderId)) {
        throw Exception('Can only submit feedback for delivered orders');
      }

      await _supabase.from('feedback').insert({
        'user_id': userId,
        'menu_item_id': menuItemId,
        'order_id': orderId,
        'rating': rating,
        'comment': comment,
      });

      // Update menu item tags based on ratings
      await _updateMenuItemTags(menuItemId);
    } catch (e) {
      rethrow;
    }
  }

  // Get feedback for a menu item
  Future<List<Feedback>> getFeedbackForMenuItem(String menuItemId) async {
    try {
      final response = await _supabase
          .from('feedback')
          .select()
          .eq('menu_item_id', menuItemId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Feedback.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get average rating for a menu item
  Future<double> getAverageRating(String menuItemId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select('average_rating')
          .eq('id', menuItemId)
          .single();

      return (response['average_rating'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Check if user can submit feedback for an order
  Future<bool> canSubmitFeedback(String orderId) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('orders')
          .select('order_status, user_id')
          .eq('id', orderId)
          .single();

      // Can only submit feedback if order is delivered and belongs to user
      return response['order_status'] == 'Delivered' && 
             response['user_id'] == userId;
    } catch (e) {
      return false;
    }
  }

  // Check if feedback already submitted for an order item
  Future<bool> hasFeedbackForOrderItem(String orderId, String menuItemId) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('feedback')
          .select()
          .eq('user_id', userId)
          .eq('order_id', orderId)
          .eq('menu_item_id', menuItemId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Update menu item tags based on ratings and popularity
  Future<void> _updateMenuItemTags(String menuItemId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select('average_rating, total_reviews')
          .eq('id', menuItemId)
          .single();

      final avgRating = (response['average_rating'] as num?)?.toDouble() ?? 0.0;
      final totalReviews = response['total_reviews'] as int? ?? 0;

      List<String> tags = [];

      // Add "Popular" tag if rating >= 4.0 and has at least 5 reviews
      if (avgRating >= 4.0 && totalReviews >= 5) {
        tags.add('Popular');
      }

      // Note: "Best Deal of the Week" should be set manually by admin
      // We'll preserve existing tags that aren't "Popular"
      final currentTags = (response['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
      for (var tag in currentTags) {
        if (tag != 'Popular' && !tags.contains(tag)) {
          tags.add(tag);
        }
      }

      await _supabase
          .from('menu_items')
          .update({'tags': tags})
          .eq('id', menuItemId);
    } catch (e) {
      // Silently fail - tags are not critical
    }
  }

  // Manually update menu item tags (admin only)
  Future<void> updateMenuItemTags(String menuItemId, List<String> tags) async {
    try {
      await _supabase
          .from('menu_items')
          .update({
            'tags': tags,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', menuItemId);
    } catch (e) {
      rethrow;
    }
  }

  // Get user's feedback history
  Future<List<Feedback>> getUserFeedbackHistory() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('feedback')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Feedback.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get pending feedback items for an order
  Future<List<Map<String, dynamic>>> getPendingFeedbackItems(String orderId) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return [];

      // Get order items
      final orderItemsResponse = await _supabase
          .from('order_items')
          .select('item_id, item_name')
          .eq('order_id', orderId);

      // Get existing feedback
      final feedbackResponse = await _supabase
          .from('feedback')
          .select('menu_item_id')
          .eq('order_id', orderId)
          .eq('user_id', userId);

      final feedbackItemIds = (feedbackResponse as List)
          .map((f) => f['menu_item_id'] as String)
          .toSet();

      // Filter out items that already have feedback
      final pendingItems = (orderItemsResponse as List)
          .where((item) => !feedbackItemIds.contains(item['item_id']))
          .map((item) => {
                'item_id': item['item_id'],
                'item_name': item['item_name'],
              })
          .toList();

      return pendingItems;
    } catch (e) {
      return [];
    }
  }
}
