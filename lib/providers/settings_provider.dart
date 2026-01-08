// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _orderNotifications = true;

  bool get orderNotifications => _orderNotifications;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _orderNotifications = prefs.getBool('orderNotifications') ?? true;
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

  Future<void> resetSettings() async {
    _orderNotifications = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orderNotifications');
  }
}
