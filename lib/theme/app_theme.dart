import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryOrange,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: AppColors.primarySwatch,
        accentColor: AppColors.secondaryOrange,
      ),
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      useMaterial3: true, // Recommended for modern Flutter apps
    );
  }
}