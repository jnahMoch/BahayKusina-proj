// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _orderNotifications = true;
  bool _promoNotifications = false;
  bool _isDarkMode = false;

  bool get orderNotifications => _orderNotifications;
  bool get promoNotifications => _promoNotifications;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _orderNotifications = prefs.getBool('orderNotifications') ?? true;
    _promoNotifications = prefs.getBool('promoNotifications') ?? false;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> setOrderNotifications(bool value) async {
    _orderNotifications = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('orderNotifications', value);
    
    // Here you can add logic to enable/disable actual push notifications
    debugPrint('Order notifications ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> setPromoNotifications(bool value) async {
    _promoNotifications = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promoNotifications', value);
    
    // Here you can add logic to enable/disable actual push notifications
    debugPrint('Promo notifications ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    
    debugPrint('Dark mode ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> resetSettings() async {
    _orderNotifications = true;
    _promoNotifications = false;
    _isDarkMode = false;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orderNotifications');
    await prefs.remove('promoNotifications');
    await prefs.remove('isDarkMode');
  }
}
