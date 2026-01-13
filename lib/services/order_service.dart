import '../config/supabase_config.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/discount_service.dart';
import '../services/delivery_service.dart';
import '../services/loyalty_service.dart';
import '../services/config_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/coupon_service.dart';
import '../models/coupon.dart';
import '../utils/constants.dart';

class OrderService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();
  final _cartService = CartService();
  final _discountService = DiscountService();
  final _deliveryService = DeliveryService();
  final _loyaltyService = LoyaltyService();
  final _configService = ConfigService();
  final _notificationService = NotificationService();
  final _couponService = CouponService();

  // Create order from cart
  Future<Order> createOrder({
    required String addressId,
    required String paymentMethod,
    double? loyaltyPointsToRedeem,
    Coupon? appliedCoupon,
    String? specialInstructions,
  }) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Check operating hours
      final isOpen = await _configService.isWithinOperatingHours();
      if (!isOpen) {
        final nextOpening = await _configService.getNextOpeningTime();
        throw Exception('Restaurant is closed. Opens at ${nextOpening?.toString().substring(11, 16) ?? "2:00 PM"}');
      }

      // Get cart items
      final cartItems = await _cartService.getCartItems();
      if (cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Get user profile for order count
      final profile = await _authService.getUserProfile();
      if (profile == null) {
        throw Exception('User profile not found');
      }

      // Calculate total
      final totalAmount = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

      // Calculate automatic discount based on order count
      final discountInfo = await _discountService.getApplicableDiscount(
        profile.totalOrders,
        totalAmount,
      );
      final discountAmount = discountInfo['amount'] as double;

      // Calculate delivery charge
      final deliveryCharge = await _deliveryService.calculateDeliveryCharge(totalAmount);

      // Calculate loyalty points redemption
      double loyaltyDiscount = 0.0;
      double loyaltyPointsUsed = 0.0;
      if (loyaltyPointsToRedeem != null && loyaltyPointsToRedeem > 0) {
        if (await _loyaltyService.canRedeemPoints(loyaltyPointsToRedeem)) {
          loyaltyDiscount = loyaltyPointsToRedeem;
          loyaltyPointsUsed = loyaltyPointsToRedeem;
        } else {
          throw Exception('Cannot redeem these loyalty points');
        }
      }

      // Calculate coupon discount
      double couponDiscount = 0.0;
      if (appliedCoupon != null) {
        couponDiscount = appliedCoupon.calculateDiscount(totalAmount);
      }

      // Calculate final amount
      final amountAfterDiscount = totalAmount - discountAmount;
      final amountAfterLoyalty = amountAfterDiscount - loyaltyDiscount;
      final amountAfterCoupon = amountAfterLoyalty - couponDiscount;
      final finalAmount = amountAfterCoupon + deliveryCharge;

      // Create order
      final orderResponse = await _supabase.from('orders').insert({
        'user_id': userId,
        'address_id': addressId,
        'total_amount': totalAmount,
        'discount_amount': discountAmount + couponDiscount, // Combine all discounts or track specifically?
        // Let's track uniquely if possible, but schema might need update.
        // Assuming discount_amount is a catch-all for now.
        'delivery_charge': deliveryCharge,
        'loyalty_points_used': loyaltyPointsUsed,
        'final_amount': finalAmount,
        'payment_method': paymentMethod,
        'payment_status': 'pending',
        'order_status': AppConstants.orderReceived,
        'special_instructions': specialInstructions,
        'coupon_id': appliedCoupon?.id,
      }).select().single();

      final orderId = orderResponse['id'];

      // Create order items
      for (final cartItem in cartItems) {
        await _supabase.from('order_items').insert({
          'order_id': orderId,
          'item_id': cartItem.itemId,
          'item_name': cartItem.menuItem?.name ?? 'Unknown',
          'quantity': cartItem.quantity,
          'is_half_plate': cartItem.isHalfPlate,
          'price': cartItem.itemPrice,
        });
      }

      // Redeem loyalty points if used
      if (loyaltyPointsUsed > 0) {
        await _supabase.from('profiles').update({
          'loyalty_points': profile.loyaltyPoints - loyaltyPointsUsed,
          'loyalty_points_redeemed': profile.loyaltyPointsRedeemed + loyaltyPointsUsed,
        }).eq('id', userId);
      }

      // Increment coupon usage
      if (appliedCoupon != null) {
        await _couponService.incrementUsage(appliedCoupon.id);
      }

      // Clear cart
      await _cartService.clearCart();

      // Trigger Notifications
      _triggerNotifications(orderResponse, cartItems);

      return Order.fromJson(orderResponse);
    } catch (e) {
      rethrow;
    }
  }

  // Calculate order preview (before placing order)
  Future<Map<String, dynamic>> calculateOrderPreview({
    double? loyaltyPointsToRedeem,
    Coupon? appliedCoupon,
  }) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Get cart items
      final cartItems = await _cartService.getCartItems();
      if (cartItems.isEmpty) {
        return {
          'total_amount': 0.0,
          'discount_amount': 0.0,
          'discount_description': '',
          'delivery_charge': 0.0,
          'loyalty_discount': 0.0,
          'final_amount': 0.0,
          'loyalty_points_to_earn': 0.0,
          'can_redeem_loyalty': false,
        };
      }

      // Get user profile
      final profile = await _authService.getUserProfile();
      if (profile == null) {
        throw Exception('User profile not found');
      }

      // Calculate total
      final totalAmount = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

      // Calculate discount
      final discountInfo = await _discountService.getApplicableDiscount(
        profile.totalOrders,
        totalAmount,
      );
      final discountAmount = discountInfo['amount'] as double;
      final discountDescription = discountInfo['description'] as String;

      // Calculate delivery charge
      final deliveryCharge = await _deliveryService.calculateDeliveryCharge(totalAmount);

      // Calculate loyalty redemption
      double loyaltyDiscount = 0.0;
      bool canRedeemLoyalty = false;
      if (loyaltyPointsToRedeem != null && loyaltyPointsToRedeem > 0) {
        canRedeemLoyalty = await _loyaltyService.canRedeemPoints(loyaltyPointsToRedeem);
        if (canRedeemLoyalty) {
          loyaltyDiscount = loyaltyPointsToRedeem;
        }
      }

      // Calculate loyalty points to earn
      final loyaltyPointsToEarn = await _loyaltyService.calculatePointsForOrder(totalAmount);

      // Calculate coupon discount
      double couponDiscount = 0.0;
      if (appliedCoupon != null) {
        couponDiscount = appliedCoupon.calculateDiscount(totalAmount);
      }

      // Calculate final amount
      final amountAfterDiscount = totalAmount - discountAmount;
      final amountAfterLoyalty = amountAfterDiscount - loyaltyDiscount;
      final amountAfterCoupon = amountAfterLoyalty - couponDiscount;
      final finalAmount = amountAfterCoupon + deliveryCharge;

      return {
        'total_amount': totalAmount,
        'discount_amount': discountAmount,
        'discount_description': discountDescription,
        'delivery_charge': deliveryCharge,
        'loyalty_discount': loyaltyDiscount,
        'coupon_discount': couponDiscount,
        'final_amount': finalAmount,
        'loyalty_points_to_earn': loyaltyPointsToEarn,
        'can_redeem_loyalty': canRedeemLoyalty,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Get user orders
  Future<List<Order>> getUserOrders() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get all orders (Admin)
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Listen to all orders (Admin)
  Stream<List<Order>> listenToAllOrders() {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((data) async {
      // For each order, we need to fetch its items because stream() doesn't support joins well
      final List<Order> orders = [];
      for (final orderJson in data) {
        final orderItemsResponse = await _supabase
            .from('order_items')
            .select()
            .eq('order_id', orderJson['id']);
        
        final orderData = Map<String, dynamic>.from(orderJson);
        orderData['order_items'] = orderItemsResponse;
        orders.add(Order.fromJson(orderData));
      }
      return orders;
    });
  }


  // Get single order
  Future<Order?> getOrder(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'order_status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      rethrow;
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus(String orderId, String status) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'payment_status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      rethrow;
    }
  }

  // Check if user can use COD
  Future<bool> canUseCOD() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return false;

      // Check if user has at least one completed UPI order
      final response = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .eq('payment_method', AppConstants.paymentUPI)
          .eq('payment_status', 'completed')
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Listen to order status changes
  Stream<Order> listenToOrderStatus(String orderId) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((data) => Order.fromJson(data.first));
  }

  // Trigger notifications asynchronously
  Future<void> _triggerNotifications(Map<String, dynamic> orderData, List cartItems) async {
    try {
      final userId = orderData['user_id'];
      
      // Fetch user profile for phone and fcm_token
      final profileResponse = await _supabase
          .from('profiles')
          .select('phone, fcm_token')
          .eq('id', userId)
          .single();
      
      final email = _authService.currentUser?.email ?? '';
      final phone = profileResponse['phone'] ?? '';
      final fcmToken = profileResponse['fcm_token'];
      final orderId = orderData['id'].toString().substring(0, 8); // Short version for SMS/Email
      final amount = orderData['final_amount'].toString();
      
      final itemsSummary = cartItems.map((item) => 
        '${item.quantity}x ${item.menuItem?.name ?? "Item"}'
      ).join(', ');

      await _notificationService.sendOrderConfirmation(
        phoneNumber: phone,
        email: email,
        orderId: orderId,
        amount: amount,
        itemsSummary: itemsSummary,
        fcmToken: fcmToken,
      );
    } catch (e) {
       // print('Error triggering notifications: $e');
    }
  }
}
