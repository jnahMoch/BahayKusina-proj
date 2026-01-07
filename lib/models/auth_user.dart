import 'address_model.dart';

enum UserRole { customer, vendor }

class AuthUser {
  final String userId;
  final String email;
  final String fullName;
  final String phone;
  final List<AddressModel> addresses;
  final UserRole role;
  final DateTime createdAt;

  const AuthUser({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.addresses,
    required this.role,
    required this.createdAt,
  });

  String get primaryAddress => addresses.isEmpty ? '' : 
      addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first).fullAddress;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'fullName': fullName,
    'phone': phone,
    'addresses': addresses.map((a) => a.toJson()).toList(),
    'role': role.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from JSON
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    var addressList = <AddressModel>[];
    if (json['addresses'] != null) {
      addressList = (json['addresses'] as List)
          .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
          .toList();
    } else if (json['address'] != null && json['address'] is String) {
      // Migrate old string address to structured list
      addressList.add(AddressModel(
        id: 'default',
        label: 'Default',
        fullName: json['fullName'] as String? ?? '',
        phoneNumber: json['phone'] as String? ?? '',
        region: '',
        province: '',
        city: '',
        barangay: '',
        streetAddress: json['address'] as String,
        postalCode: '',
        latitude: 0.0,
        longitude: 0.0,
        isDefault: true,
      ));
    }

    return AuthUser(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addresses: addressList,
      role: (json['role']?.toString().toLowerCase().trim() == 'vendor')
          ? UserRole.vendor
          : UserRole.customer,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : (json['createdAt'] is DateTime
                ? json['createdAt'] as DateTime
                : DateTime.now()),
    );
  }

  /// Create a copy with modifications
  AuthUser copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? phone,
    List<AddressModel>? addresses,
    UserRole? role,
    DateTime? createdAt,
  }) => AuthUser(
    userId: userId ?? this.userId,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    addresses: addresses ?? this.addresses,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
  );
}
