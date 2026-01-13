class ServiceRadius {
  final String id;
  final String pincode;
  final String city;
  final String? area;
  final double distanceKm;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceRadius({
    required this.id,
    required this.pincode,
    required this.city,
    this.area,
    required this.distanceKm,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceRadius.fromJson(Map<String, dynamic> json) {
    return ServiceRadius(
      id: json['id'] as String,
      pincode: json['pincode'] as String,
      city: json['city'] as String,
      area: json['area'] as String?,
      distanceKm: (json['distance_km'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pincode': pincode,
      'city': city,
      'area': area,
      'distance_km': distanceKm,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isWithinServiceRange => distanceKm >= 3.0 && distanceKm <= 6.0;

  ServiceRadius copyWith({
    String? pincode,
    String? city,
    String? area,
    double? distanceKm,
    bool? isActive,
  }) {
    return ServiceRadius(
      id: id,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      area: area ?? this.area,
      distanceKm: distanceKm ?? this.distanceKm,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
