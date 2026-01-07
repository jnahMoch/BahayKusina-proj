// lib/services/geocoding_service.dart
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();

  factory GeocodingService() {
    return _instance;
  }

  GeocodingService._internal();

  /// Convert an address string to GPS coordinates (LatLng)
  /// Returns null if geocoding fails
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      if (address.trim().isEmpty) return null;
      
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      
      return null;
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }

  /// Convert GPS coordinates to detailed address components
  Future<Placemark?> getPlaceMarkFromCoordinates(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  /// Convert GPS coordinates to a formatted address string
  /// Returns null if reverse geocoding fails
  Future<String?> getAddressFromCoordinates(LatLng location) async {
    try {
      final placemark = await getPlaceMarkFromCoordinates(location);
      if (placemark != null) {
        // Build a formatted address from the placemark
        List<String> addressParts = [];
        
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          addressParts.add(placemark.subLocality!);
        }
        
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }
        
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          addressParts.add(placemark.country!);
        }

        return addressParts.join(', ');
      }

      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  /// Get a short formatted address (street and locality only)
  Future<String?> getShortAddress(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        List<String> addressParts = [];
        
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }

        return addressParts.join(', ');
      }

      return null;
    } catch (e) {
      print('Error getting short address: $e');
      return null;
    }
  }
}
