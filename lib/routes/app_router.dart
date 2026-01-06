import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/home_page.dart';
import '../screens/signup_page.dart';
import '../screens/notifications.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginPage(),
      signup: (context) => const SignUpPage(),
      home: (context) => const HomePage(),
      notifications: (context) => const NotificationsPage(),
    };
  }
}
