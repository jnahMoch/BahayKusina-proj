import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color secondaryOrange = Color(0xFFFF8C3B);
  static const Color primaryOrangeLight = Color(0xFFFF8C3B); // Lighter orange
  static const Color selectorBackground = Color(0xFFFFF3E0); // Light orange background for selectors
  static const Color fieldBackground = Color.fromARGB(255, 247, 243, 243);
  static const Color inputFillColor = Color(0xFFF5F5F5);
  static const Color textGrey = Color.fromARGB(179, 122, 121, 121);
  static const Color scaffoldBackground = Color(0xFFF0F0F0);

  // Custom MaterialColor for the primarySwatch
  static final MaterialColor primarySwatch = MaterialColor(
    primaryOrange.value,
    const <int, Color>{
      50: Color(0xFFFFE0B2),
      100: Color(0xFFFFCC80),
      200: Color(0xFFFFB74D),
      300: Color(0xFFFFA726),
      400: Color(0xFFFF9800),
      500: primaryOrange,
      600: Color(0xFFF57C00),
      700: Color(0xFFE65100),
      800: Color(0xFFD84315),
      900: Color(0xFFBF360C),
    },
  );
}