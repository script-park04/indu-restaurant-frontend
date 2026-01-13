class Order {
  final String id;
  final String userId;
  final String? addressId;
  final double totalAmount;
  final double discountAmount;
  final double deliveryCharge;
  final double finalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String? specialInstructions;
  final double loyaltyPointsUsed;
  final double loyaltyPointsEarned;
  final int? orderNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  List<OrderItem>? items;

  Order({
    required this.id,
    required this.userId,
    this.addressId,
    required this.totalAmount,
    this.discountAmount = 0,
    this.deliveryCharge = 0,
    required this.finalAmount,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.orderStatus = 'Order Received',
    this.specialInstructions,
    this.loyaltyPointsUsed = 0,
    this.loyaltyPointsEarned = 0,
    this.orderNumber,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      addressId: json['address_id'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      deliveryCharge: (json['delivery_charge'] as num?)?.toDouble() ?? 0,
      finalAmount: (json['final_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      orderStatus: json['order_status'] as String? ?? 'Order Received',
      specialInstructions: json['special_instructions'] as String?,
      loyaltyPointsUsed: (json['loyalty_points_used'] as num?)?.toDouble() ?? 0,
      loyaltyPointsEarned: (json['loyalty_points_earned'] as num?)?.toDouble() ?? 0,
      orderNumber: json['order_number'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: json['order_items'] != null
          ? (json['order_items'] as List)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'address_id': addressId,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'delivery_charge': deliveryCharge,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'special_instructions': specialInstructions,
      'loyalty_points_used': loyaltyPointsUsed,
      'loyalty_points_earned': loyaltyPointsEarned,
      'order_number': orderNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String itemId;
  final String itemName;
  final int quantity;
  final bool isHalfPlate;
  final double price;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    this.isHalfPlate = false,
    required this.price,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String,
      quantity: json['quantity'] as int,
      isHalfPlate: json['is_half_plate'] as bool? ?? false,
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'is_half_plate': isHalfPlate,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get totalPrice => price * quantity;
}
