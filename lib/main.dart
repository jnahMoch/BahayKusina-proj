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
import 'providers/settings_provider.dart';
import 'providers/local_package_provider.dart';
import 'services/notification_service.dart';
import 'services/firestore_service.dart';
import 'models/auth_user.dart';
import 'screens/home_page.dart';
import 'screens/vendor_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize Firestore with persistence for offline support
  await FirestoreService.initialize();

  final authProvider = AuthProvider();
  // Auth state will be monitored by the authStateChanges listener
  // No need to await here as it sets up a listener
  authProvider.checkAuthStatus();

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
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LocalPackageProvider()),
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
        print('⚠️ AuthWrapper: isAuthenticated=true but user is null!');
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
          ),
        );
      }

      print('🏠 AuthWrapper BUILD:');
      print('   email = ${user.email}');
      print('   role = ${user.role}');
      print('   isVendor = ${user.role == UserRole.vendor}');
      
      if (user.role == UserRole.vendor) {
        print('🏠 AuthWrapper: → VendorHomePage');
        return const VendorHomePage();
      }
      print('🏠 AuthWrapper: → HomePage (Customer)');
      return const HomePage();
    }

    return const WelcomeScreen();
  }
}
