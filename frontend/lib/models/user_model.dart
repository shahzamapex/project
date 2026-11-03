class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // owner, engineer, client
  final String phone;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone = '',
    this.avatarUrl = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['email'] ?? 'User',
      role: json['role'] ?? 'client',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }
}
