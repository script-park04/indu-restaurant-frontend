class QRCode {
  final String id;
  final String name;
  final String content;
  final String? qrImageUrl;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final String? createdBy;

  QRCode({
    required this.id,
    required this.name,
    required this.content,
    this.qrImageUrl,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.createdBy,
  });

  factory QRCode.fromJson(Map<String, dynamic> json) {
    return QRCode(
      id: json['id'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
      qrImageUrl: json['qr_image_url'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'qr_image_url': qrImageUrl,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }
}
