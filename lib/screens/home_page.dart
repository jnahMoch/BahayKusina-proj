<<<<<<< HEAD
// lib/screens/home_page.dart

=======
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
<<<<<<< HEAD
  final FirestoreService _firestoreService = FirestoreService();
  List<MealPackage> _allMeals = List.from(_fallbackMeals);
  bool _isLoading = false;

  // Fallback data if Firestore is empty/offline
  static final List<MealPackage> _fallbackMeals = [
    const MealPackage(
      type: 'Breakfast',
      title: 'Silog Special',
      vendor: 'Aling Nena\'s Kitchen',
      vendorId: 'fallback_1',
      desc:
          'Classic Filipino breakfast with garlic rice, egg, and choice of meat.',
      price: 120,
      left: 15,
      imageUrl: 'https://images.unsplash.com/photo-1626074353765-517a681e40be',
    ),
    const MealPackage(
      type: 'Lunch',
      title: 'Adobo Rice Bowl',
      vendor: 'Mama Joy\'s House',
      vendorId: 'fallback_2',
      desc: 'Savory chicken and pork adobo served over warm white rice.',
      price: 150,
      left: 10,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
    ),
    const MealPackage(
      type: 'Dinner',
      title: 'Sinigang na Baboy',
      vendor: 'Kusina de Manila',
      vendorId: 'fallback_3',
      desc: 'Sour tamarind soup with tender pork and local vegetables.',
      price: 180,
      left: 5,
      imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19',
    ),
    const MealPackage(
      type: 'Merienda',
      title: 'Pancit Guisado',
      vendor: 'Lola\'s Panciteria',
      vendorId: 'fallback_4',
      desc: 'Stir-fried noodles with crisp vegetables and savory toppings.',
      price: 90,
      left: 20,
      imageUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246',
    ),
    const MealPackage(
      type: 'Dessert',
      title: 'Leche Flan',
      vendor: 'Sweet Treats',
      vendorId: 'fallback_5',
      desc: 'Rich and creamy custard with a caramelized sugar topping.',
      price: 75,
      left: 12,
      imageUrl: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc2fe0a',
=======
  final List<MealPackage> mealPackages = [
    const MealPackage(
      type: 'Breakfast',
      title: 'Ultimate Breakfast Package',
      vendor: "Nanay's Kitchen",
      desc: 'Start your day right with a hearty Filipino breakfast',
      price: 150,
      left: 20,
      imageUrl: 'assets/images/food_package_1.jpg',
    ),
    const MealPackage(
      type: 'Lunch',
      title: 'Lunch Value Pack',
      vendor: "Nanay's Kitchen",
      desc: 'Complete lunch meal for the whole family',
      price: 350,
      left: 15,
      imageUrl: 'assets/images/food_package_2.jpg',
    ),
    const MealPackage(
      type: 'Merienda',
      title: 'Merienda Bundle',
      vendor: "Lola's Lutong Bahay",
      desc: 'Perfect afternoon snacks for the family',
      price: 180,
      left: 8,
      imageUrl: 'assets/images/food_package_1.jpg',
    ),
    const MealPackage(
      type: 'Dinner',
      title: 'Family Dinner Feast',
      vendor: "Ate's Specialties",
      desc: 'A satisfying meal for four, ready to serve',
      price: 499,
      left: 12,
      imageUrl: 'assets/images/food_package_2.jpg',
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
    ),
  ];

  @override
<<<<<<< HEAD
  void initState() {
    super.initState();
    // Start with fallback meals immediately so the page is never empty
    _allMeals = List.from(_fallbackMeals);
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final meals = await _firestoreService.getMealPackages();
      if (mounted) {
        setState(() {
          // If Firestore returns real data, update the list.
          // If it returns empty (e.g. offline), we keep the fallback meals.
          if (meals.isNotEmpty) {
            _allMeals = meals;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allMeals = _fallbackMeals;
          _isLoading = false;
        });
      }
    }
  }

  @override
=======
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    const List<String> categories = [
      'All',
      'Breakfast',
      'Lunch',
      'Dinner',
      'Merienda',
      'Dessert',
    ];

<<<<<<< HEAD
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
                            cartProvider: Provider.of<CartProvider>(context),
                            onOrderAdded: () {
                              setState(() {});
                            },
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
=======
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Gradient and Search
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [HomePage.primaryOrange, Color(0xFFFF4800)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildHeaderContent(context, cartProvider),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSearchBar(),
                  ),
                ],
              ),
            ),

            // Category Selector
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == 'All';
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? HomePage.primaryOrange : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Section Header
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Available Packages',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'From local home-based vendors',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            // Meal List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              itemCount: mealPackages.length,
              itemBuilder: (context, index) {
                return MealCard(
                  meal: mealPackages[index],
                  cartProvider: cartProvider,
                );
              },
            ),
          ],
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

<<<<<<< HEAD
  Widget _buildHeaderContent(BuildContext context) {
=======
  Widget _buildHeaderContent(BuildContext context, CartProvider cartProvider) {
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.bakery_dining_outlined,
              color: Colors.white,
              size: 40,
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
<<<<<<< HEAD
            _buildHeaderIcon(context, Icons.notifications_none, true),
            const SizedBox(width: 8),
            _buildHeaderIcon(context, Icons.shopping_bag_outlined, false),
=======
            _buildHeaderIcon(context, Icons.shopping_bag_outlined, false, cartProvider),
            const SizedBox(width: 5),
            _buildHeaderIcon(context, Icons.notifications_none_outlined, true, cartProvider),
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
          ],
        ),
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildHeaderIcon(BuildContext context, IconData icon, bool hasBadge) {
    final notificationService = Provider.of<NotificationService>(context);
    final cartProvider = Provider.of<CartProvider>(context);

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
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    cartProvider: cartProvider,
                    onCheckout: () {
                      cartProvider.clearCart();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Order placed successfully!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Color(0xFF4CAF50),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ),
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
=======
  Widget _buildHeaderIcon(BuildContext context, IconData icon, bool hasBadge, CartProvider cartProvider) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(icon, color: Colors.white, size: 28),
              onPressed: () {
                if (hasBadge) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()),
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
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: HomePage.accentRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
            else if (!hasBadge && cartProvider.totalQuantity > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: HomePage.accentRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      cartProvider.totalQuantity.toString(),
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
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
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
<<<<<<< HEAD
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
=======
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 28), activeIcon: Icon(Icons.home, size: 28), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined, size: 28), activeIcon: Icon(Icons.shopping_bag, size: 28), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded, size: 28), activeIcon: Icon(Icons.person, size: 28), label: 'Profile'),
      ],
      onTap: (index) {
        if (index == 0) {
        } else if (index == 1) {
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
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
