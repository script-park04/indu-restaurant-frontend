import 'menu_item.dart';

class CartItem {
  final String id;
  final String userId;
  final String itemId;
  final int quantity;
  final bool isHalfPlate;
  final DateTime createdAt;
  MenuItem? menuItem; // Populated via join

  CartItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.quantity,
    this.isHalfPlate = false,
    required this.createdAt,
    this.menuItem,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemId: json['item_id'] as String,
      quantity: json['quantity'] as int,
      isHalfPlate: json['is_half_plate'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      menuItem: json['menu_items'] != null 
          ? MenuItem.fromJson(json['menu_items'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_id': itemId,
      'quantity': quantity,
      'is_half_plate': isHalfPlate,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get itemPrice {
    if (menuItem == null) return 0;
    return isHalfPlate && menuItem!.halfPlatePrice != null
        ? menuItem!.halfPlatePrice!
        : menuItem!.price;
  }

  double get totalPrice => itemPrice * quantity;

  CartItem copyWith({
    int? quantity,
    bool? isHalfPlate,
  }) {
    return CartItem(
      id: id,
      userId: userId,
      itemId: itemId,
      quantity: quantity ?? this.quantity,
      isHalfPlate: isHalfPlate ?? this.isHalfPlate,
      createdAt: createdAt,
      menuItem: menuItem,
    );
  }
}
