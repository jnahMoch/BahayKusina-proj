// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsProvider extends ChangeNotifier {
  bool _orderNotifications = true;
  bool _promoNotifications = false;
  bool _isDarkMode = false;
  bool _isStoreOpen = true;
  int _preparationTime = 30; // minutes
  bool _autoAcceptOrders = false;
  String? _vendorId;

  bool get orderNotifications => _orderNotifications;
  bool get promoNotifications => _promoNotifications;
  bool get isDarkMode => _isDarkMode;
  bool get isStoreOpen => _isStoreOpen;
  int get preparationTime => _preparationTime;
  bool get autoAcceptOrders => _autoAcceptOrders;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsProvider() {
    _loadSettings();
  }

  /// Initialize vendor-specific settings
  Future<void> initVendorSettings(String vendorId) async {
    _vendorId = vendorId;
    await _loadVendorSettings(vendorId);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _orderNotifications = prefs.getBool('orderNotifications') ?? true;
    _promoNotifications = prefs.getBool('promoNotifications') ?? false;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isStoreOpen = prefs.getBool('isStoreOpen') ?? true;
    _preparationTime = prefs.getInt('preparationTime') ?? 30;
    _autoAcceptOrders = prefs.getBool('autoAcceptOrders') ?? false;
    notifyListeners();
  }

  Future<void> _loadVendorSettings(String vendorId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _isStoreOpen = data['isStoreOpen'] ?? true;
        _preparationTime = data['preparationTime'] ?? 30;
        _autoAcceptOrders = data['autoAcceptOrders'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading vendor settings: $e');
    }
  }

  Future<void> setOrderNotifications(bool value) async {
    _orderNotifications = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('orderNotifications', value);

    debugPrint('Order notifications ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> setPromoNotifications(bool value) async {
    _promoNotifications = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promoNotifications', value);

    debugPrint('Promo notifications ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);

    debugPrint('Dark mode ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> setStoreOpen(bool value, {String? vendorId}) async {
    _isStoreOpen = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isStoreOpen', value);

    // Also update Firestore for vendor
    final vid = vendorId ?? _vendorId;
    if (vid != null) {
      try {
        await FirebaseFirestore.instance.collection('vendors').doc(vid).set({
          'isStoreOpen': value,
        }, SetOptions(merge: true));
        debugPrint(
          'Store status updated in Firestore: ${value ? 'OPEN' : 'CLOSED'}',
        );
      } catch (e) {
        debugPrint('Error updating store status: $e');
      }
    }

    debugPrint('Store is now ${value ? 'OPEN' : 'CLOSED'}');
  }

  Future<void> setPreparationTime(int minutes, {String? vendorId}) async {
    _preparationTime = minutes;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('preparationTime', minutes);

    // Also update Firestore for vendor
    final vid = vendorId ?? _vendorId;
    if (vid != null) {
      try {
        await FirebaseFirestore.instance.collection('vendors').doc(vid).set({
          'preparationTime': minutes,
        }, SetOptions(merge: true));
        debugPrint('Preparation time updated in Firestore: $minutes mins');
      } catch (e) {
        debugPrint('Error updating preparation time: $e');
      }
    }

    debugPrint('Preparation time set to $minutes minutes');
  }

  Future<void> setAutoAcceptOrders(bool value, {String? vendorId}) async {
    _autoAcceptOrders = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoAcceptOrders', value);

    // Also update Firestore for vendor
    final vid = vendorId ?? _vendorId;
    if (vid != null) {
      try {
        await FirebaseFirestore.instance.collection('vendors').doc(vid).set({
          'autoAcceptOrders': value,
        }, SetOptions(merge: true));
        debugPrint('Auto-accept orders updated in Firestore: $value');
      } catch (e) {
        debugPrint('Error updating auto-accept: $e');
      }
    }

    debugPrint('Auto-accept orders ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> resetSettings() async {
    _orderNotifications = true;
    _promoNotifications = false;
    _isDarkMode = false;
    _isStoreOpen = true;
    _preparationTime = 30;
    _autoAcceptOrders = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orderNotifications');
    await prefs.remove('promoNotifications');
    await prefs.remove('isDarkMode');
    await prefs.remove('isStoreOpen');
    await prefs.remove('preparationTime');
    await prefs.remove('autoAcceptOrders');
  }
}
