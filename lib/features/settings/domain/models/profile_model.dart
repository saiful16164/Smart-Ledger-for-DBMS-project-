class ProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
