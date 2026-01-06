// lib/models/meal_package.dart
import 'package:flutter/material.dart';

class MealPackage {
  final String type;
  final String title;
  final String vendor;
  final String desc;
  final int price;
  final int left;
  final String imageUrl;

  const MealPackage({
    required this.type,
    required this.title,
    required this.vendor,
    required this.desc,
    required this.price,
    required this.left,
    required this.imageUrl,
  });

  // OOP: Logic lives in the data model
  bool get isLowStock => left > 0 && left <= 5;
  bool get isOutOfStock => left == 0;

  Color get stockColor {
    if (isOutOfStock) return Colors.grey;
    if (isLowStock) return Colors.redAccent; // Urgent color
    return const Color(0xFF4CAF50); // Healthy stock color (Green)
  }
}