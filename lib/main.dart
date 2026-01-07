import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/vendor_provider.dart';
import 'services/notification_service.dart';
import 'models/auth_user.dart';
import 'screens/home_page.dart';
import 'screens/vendor_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus(); // Check if user is already logged in

  runApp(BahayKusinaApp(authProvider: authProvider));
}

class BahayKusinaApp extends StatelessWidget {
  final AuthProvider authProvider;

  const BahayKusinaApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
      ],
      child: MaterialApp(
        title: 'BahayKusina',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      final user = authProvider.currentUser;

      // Safety check: ensure user object is fully populated before navigating
      if (user == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
          ),
        );
      }

      if (user.role == UserRole.vendor) {
        return const VendorHomePage();
      }
      return const HomePage();
    }

    return const WelcomeScreen();
  }
}
