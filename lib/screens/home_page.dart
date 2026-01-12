import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'meal_card.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';
import 'notifications.dart';
import '../models/meal_package.dart';
import '../providers/cart_provider.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color secondaryOrange = Color(0xFFFF8C3B);
  static const Color accentRed = Color(0xFFE53935);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<MealPackage> _allMeals = List.from(_fallbackMeals);
  bool _isLoading = false;
  StreamSubscription<List<MealPackage>>? _mealsSubscription;

  // Fallback data if Firestore is empty/offline
  static final List<MealPackage> _fallbackMeals = [
    const MealPackage(
      type: 'Breakfast',
      title: 'Breakfast Package',
      vendor: 'Aling Nena\'s Kitchen',
      vendorId: 'fallback_1',
      desc:
          'Start your day right with a satisfying breakfast to energize your morning.',
      price: 1500.0,
      left: 15,
      imageUrl: 'https://foodtray2go.com/wp-content/uploads/2022/09/image6-1024x764.jpg',
    ),
    const MealPackage(
      type: 'Lunch',
      title: 'Lunch Package',
      vendor: 'Mama Joy\'s House',
      vendorId: 'fallback_2',
      desc: 'Enjoy a filling lunch to keep you energized throughout the day.',
      price: 1500.0,
      left: 10,
      imageUrl: 'https://foodtray2go.com/wp-content/uploads/2025/08/175429137061475-1-scaled.jpg',
    ),
    const MealPackage(
      type: 'Dinner',
      title: 'Dinner Package',
      vendor: 'Kusina de Manila',
      vendorId: 'fallback_3',
      desc: 'End your day with a comforting dinner to relax and recharge.',
      price: 3500.0,
      left: 5,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXjohmUbTgfrA3ovVMCtrlBNCtJ4QtHqjlqA&s',
    ),
    const MealPackage(
      type: 'Merienda',
      title: 'Merienda Package',
      vendor: 'Lola\'s Panciteria',
      vendorId: 'fallback_4',
      desc: 'Enjoy a delightful afternoon snack to brighten your day.',
      price: 599.0,
      left: 20,
      imageUrl: 'https://i0.wp.com/www.greenecoparadise.com/wp-content/uploads/Catering-Tray-Promo-1.jpg?resize=1024%2C778&ssl=1',
    ),
    const MealPackage(
      type: 'Dessert',
      title: 'Dessert Package',
      vendor: 'Sweet Treats',
      vendorId: 'fallback_5',
      desc: 'Treat yourself to a sweet dessert for a perfect finish to your meal.',
      price: 2000.0,
      left: 12,
      imageUrl: 'https://www.shutterstock.com/image-photo/dessert-fruit-buffet-tray-lots-600w-645283051.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    print('🏠 HomePage: initState called');
    // Start with fallback meals immediately so the page is never empty
    _allMeals = List.from(_fallbackMeals);
    _fetchMeals();
    _startRealtimeMealUpdates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh meals when page becomes visible
    print('🏠 HomePage: didChangeDependencies - refreshing meals');
    _fetchMeals();
  }

  @override
  void dispose() {
    _mealsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchMeals() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    print('🔄 HomePage: Manual refresh triggered');

    try {
      final meals = await _firestoreService.getMealPackages();
      print('🔄 HomePage: Fetched ${meals.length} meals from Firestore');
      if (mounted) {
        setState(() {
          // If Firestore returns real data, update the list.
          // If it returns empty (e.g. offline), we keep the fallback meals.
          if (meals.isNotEmpty) {
            _allMeals = meals;
            print('🔄 HomePage: Updated UI with ${meals.length} meals');
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔄 HomePage: Fetch error: $e');
      if (mounted) {
        setState(() {
          _allMeals = _fallbackMeals;
          _isLoading = false;
        });
      }
    }
    
    // Restart the real-time stream to ensure it's active
    _startRealtimeMealUpdates();
  }

  void _startRealtimeMealUpdates() {
    print('🏠 HomePage: Starting real-time meal updates stream');

    // Cancel any existing subscription
    _mealsSubscription?.cancel();

    _mealsSubscription = _firestoreService.streamAllMeals().listen(
      (meals) {
        print('🏠 HomePage: REAL-TIME UPDATE RECEIVED! ${meals.length} meals');
        for (var meal in meals) {
          print('   📦 ${meal.title} by ${meal.vendor} (ID: ${meal.id})');
        }
        if (mounted) {
          setState(() {
            if (meals.isNotEmpty) {
              _allMeals = meals;
              print('🏠 HomePage: UI updated with ${meals.length} meals');
            } else {
              print('🏠 HomePage: Empty list received, keeping current data');
            }
          });
        }
      },
      onError: (error) {
        print('🏠 HomePage: Stream ERROR: $error');
      },
    );
    
    print('🏠 HomePage: Stream subscription active');
  }

  @override
  Widget build(BuildContext context) {
    const List<String> categories = [
      'All',
      'Breakfast',
      'Lunch',
      'Dinner',
      'Merienda',
      'Dessert',
    ];

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: true,
                pinned: true,
                snap: true,
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: HomePage.primaryOrange,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          HomePage.primaryOrange,
                          HomePage.secondaryOrange,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 10,
                          left: 20,
                          right: 20,
                          child: _buildHeaderContent(context),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(135.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        child: _buildSearchBar(),
                      ),
                      TabBar(
                        isScrollable: true,
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withOpacity(0.7),
                        tabAlignment: TabAlignment.start,
                        padding: const EdgeInsets.only(left: 15, bottom: 8),
                        tabs: categories
                            .map(
                              (name) => Tab(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0,
                                    vertical: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: (_isLoading && _allMeals.isEmpty)
              ? const Center(
                  child: CircularProgressIndicator(
                    color: HomePage.primaryOrange,
                  ),
                )
              : TabBarView(
                  children: categories.map((category) {
                    final filteredPackages = category == 'All'
                        ? _allMeals
                        : _allMeals
                              .where((meal) => meal.type == category)
                              .toList();

                    if (filteredPackages.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: _fetchMeals,
                      color: HomePage.primaryOrange,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 10.0,
                        ),
                        itemCount: filteredPackages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildListHeader();
                          }

                          final mealPackage = filteredPackages[index - 1];

                          return MealCard(
                            meal: mealPackage,
                            onOrderAdded: () {
                              setState(() {});
                            },
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
        ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/bahay_kusina_logo.png',
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "BahayKusina",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "Meal Packages",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Refresh button
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                print('🔄 Manual refresh button pressed');
                _fetchMeals();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing meals...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            _buildHeaderIcon(context, Icons.notifications_none, true),
            const SizedBox(width: 8),
            _buildHeaderIcon(context, Icons.shopping_bag_outlined, false),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(BuildContext context, IconData icon, bool hasBadge) {
    return Consumer2<NotificationService, CartProvider>(
      builder: (context, notificationService, cartProvider, child) {
        return Stack(
          children: [
            IconButton(
              icon: Icon(icon, color: Colors.white, size: 26),
              onPressed: () {
                if (hasBadge) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                }
              },
            ),
            if (hasBadge && notificationService.unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: HomePage.accentRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      notificationService.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            else if (!hasBadge && cartProvider.itemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: HomePage.accentRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      cartProvider.itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search meal packages...",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Packages',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'From local home-based vendors in your area',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No packages available in this category",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      elevation: 20,
      selectedItemColor: HomePage.primaryOrange,
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrdersPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
      },
    );
  }
}
