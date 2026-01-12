import 'package:flutter/material.dart';
import '../models/meal_package.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalPackageProvider extends ChangeNotifier {
  static const _storageKey = 'local_meal_packages';
  List<MealPackage> _packages = [];

  List<MealPackage> get packages => _packages;

  LocalPackageProvider() {
    loadPackages();
  }

  Future<void> loadPackages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List;
      _packages = decoded.map((e) => _fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> addPackage(MealPackage pkg) async {
    _packages.add(pkg);
    await _savePackages();
    notifyListeners();
  }

  Future<void> _savePackages() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_packages.map(_toJson).toList());
    await prefs.setString(_storageKey, encoded);
  }

  MealPackage _fromJson(Map<String, dynamic> json) {
    return MealPackage(
      id: json['id'] ?? '',
      type: json['type'],
      title: json['title'],
      vendor: json['vendor'],
      vendorId: json['vendorId'],
      desc: json['desc'],
      price: (json['price'] as num).toDouble(),
      left: json['left'],
      imageUrl: json['imageUrl'],
      packageItems: List<String>.from(json['packageItems'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> _toJson(MealPackage pkg) {
    return {
      'id': pkg.id,
      'type': pkg.type,
      'title': pkg.title,
      'vendor': pkg.vendor,
      'vendorId': pkg.vendorId,
      'desc': pkg.desc,
      'price': pkg.price,
      'left': pkg.left,
      'imageUrl': pkg.imageUrl,
      'packageItems': pkg.packageItems,
      'isAvailable': pkg.isAvailable,
    };
  }
}
