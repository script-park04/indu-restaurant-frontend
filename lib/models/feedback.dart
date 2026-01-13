class Feedback {
  final String id;
  final String userId;
  final String menuItemId;
  final String orderId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Feedback({
    required this.id,
    required this.userId,
    required this.menuItemId,
    required this.orderId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      menuItemId: json['menu_item_id'] as String,
      orderId: json['order_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'menu_item_id': menuItemId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
