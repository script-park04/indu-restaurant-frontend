class SpecialDiscount {
  final String id;
  final String name;
  final String? description;
  final double discountPercent;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> applicableDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SpecialDiscount({
    required this.id,
    required this.name,
    this.description,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    this.applicableDays = const [0, 1, 2, 3, 4, 5, 6],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpecialDiscount.fromJson(Map<String, dynamic> json) {
    return SpecialDiscount(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      discountPercent: (json['discount_percent'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      applicableDays: (json['applicable_days'] as List?)?.map((e) => e as int).toList() ?? [0, 1, 2, 3, 4, 5, 6],
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discount_percent': discountPercent,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'applicable_days': applicableDays,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCurrentlyActive {
    if (!isActive) return false;
    
    final now = DateTime.now();
    if (now.isBefore(startDate) || now.isAfter(endDate)) return false;
    
    // Check if today is an applicable day (0=Sunday, 6=Saturday)
    final today = now.weekday % 7; // Convert to 0-6 format
    return applicableDays.contains(today);
  }

  SpecialDiscount copyWith({
    String? name,
    String? description,
    double? discountPercent,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? applicableDays,
    bool? isActive,
  }) {
    return SpecialDiscount(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountPercent: discountPercent ?? this.discountPercent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      applicableDays: applicableDays ?? this.applicableDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
