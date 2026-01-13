class MenuItem {
  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final double price;
  final double? halfPlatePrice;
  final String? imageUrl;
  final bool isAvailable;
  final bool isBestseller;
  final bool isVegetarian;
  final int displayOrder;
  final double averageRating;
  final int totalReviews;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    required this.price,
    this.halfPlatePrice,
    this.imageUrl,
    this.isAvailable = true,
    this.isBestseller = false,
    this.isVegetarian = true,
    this.displayOrder = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      price: (json['price'] as num).toDouble(),
      halfPlatePrice: (json['half_plate_price'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      isBestseller: json['is_bestseller'] as bool? ?? false,
      isVegetarian: json['is_vegetarian'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'price': price,
      'half_plate_price': halfPlatePrice,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'is_bestseller': isBestseller,
      'is_vegetarian': isVegetarian,
      'display_order': displayOrder,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MenuItem copyWith({
    String? name,
    String? description,
    String? categoryId,
    double? price,
    double? halfPlatePrice,
    String? imageUrl,
    bool? isAvailable,
    bool? isBestseller,
    bool? isVegetarian,
    int? displayOrder,
    double? averageRating,
    int? totalReviews,
    List<String>? tags,
  }) {
    return MenuItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      halfPlatePrice: halfPlatePrice ?? this.halfPlatePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isBestseller: isBestseller ?? this.isBestseller,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      displayOrder: displayOrder ?? this.displayOrder,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Helper getters
  bool get isPopular => tags.contains('Popular');
  bool get isBestDeal => tags.contains('Best Deal of the Week');
  bool get hasGoodRating => averageRating >= 4.0;
}
