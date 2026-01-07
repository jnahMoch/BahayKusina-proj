import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressModel {
  final String id;
  final String label; // Home, Work, etc.
  final String fullName;
  final String phoneNumber;
  final String region;
  final String province;
  final String city;
  final String barangay;
  final String streetAddress;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phoneNumber,
    required this.region,
    required this.province,
    required this.city,
    required this.barangay,
    required this.streetAddress,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  String get fullAddress =>
      '$streetAddress, $barangay, $city, $province, $region $postalCode';

  String get conciseAddress => '$streetAddress, $barangay, $city';

  LatLng get coordinates => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'region': region,
    'province': province,
    'city': city,
    'barangay': barangay,
    'streetAddress': streetAddress,
    'postalCode': postalCode,
    'latitude': latitude,
    'longitude': longitude,
    'isDefault': isDefault,
  };

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['id'] as String? ?? '',
    label: json['label'] as String? ?? 'Home',
    fullName: json['fullName'] as String? ?? '',
    phoneNumber: json['phoneNumber'] as String? ?? '',
    region: json['region'] as String? ?? '',
    province: json['province'] as String? ?? '',
    city: json['city'] as String? ?? '',
    barangay: json['barangay'] as String? ?? '',
    streetAddress: json['streetAddress'] as String? ?? '',
    postalCode: json['postalCode'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    isDefault: json['isDefault'] as bool? ?? false,
  );

  AddressModel copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phoneNumber,
    String? region,
    String? province,
    String? city,
    String? barangay,
    String? streetAddress,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) => AddressModel(
    id: id ?? this.id,
    label: label ?? this.label,
    fullName: fullName ?? this.fullName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    region: region ?? this.region,
    province: province ?? this.province,
    city: city ?? this.city,
    barangay: barangay ?? this.barangay,
    streetAddress: streetAddress ?? this.streetAddress,
    postalCode: postalCode ?? this.postalCode,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    isDefault: isDefault ?? this.isDefault,
  );
}
