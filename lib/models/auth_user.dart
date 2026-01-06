enum UserRole { customer, vendor }

class AuthUser {
  final String userId;
  final String email;
  final String fullName;
  final String phone;
  final String address;
  final UserRole role;
  final DateTime createdAt;

  const AuthUser({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.role,
    required this.createdAt,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'fullName': fullName,
    'phone': phone,
    'address': address,
    'role': role.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from JSON
  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    userId: json['userId'] as String? ?? '',
    email: json['email'] as String? ?? '',
    fullName: json['fullName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    address: json['address'] as String? ?? '',
    role: json['role'] == 'vendor' ? UserRole.vendor : UserRole.customer,
    createdAt: json['createdAt'] is String
        ? DateTime.parse(json['createdAt'] as String)
        : (json['createdAt'] as DateTime? ?? DateTime.now()),
  );

  /// Create a copy with modifications
  AuthUser copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? phone,
    String? address,
    UserRole? role,
    DateTime? createdAt,
  }) => AuthUser(
    userId: userId ?? this.userId,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
  );
}
