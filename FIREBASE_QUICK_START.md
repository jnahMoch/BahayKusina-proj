# BahayKusina Firebase Integration - Quick Start

## Prerequisites
- Firebase account (free tier works)
- Flutter SDK installed
- Android Studio or Xcode

## Quick Setup (5 minutes)

### 1. Create Firebase Project
```
1. Go to https://console.firebase.google.com/
2. Click "Create a project"
3. Name: "BahayKusina"
4. Click "Create project"
5. Wait for creation to complete
```

### 2. Download google-services.json
```
1. In Firebase Console, click "Android"
2. Package name: com.bahaykusina.app
3. Download google-services.json
4. Move to: android/app/google-services.json
```

### 3. Run flutterfire configure
```bash
cd /path/to/bahaykusina
flutterfire configure
# Select Android
# Select BahayKusina project
# Wait for completion
```

### 4. Enable Authentication
```
Firebase Console → Authentication → Sign-in method
Enable: Email/Password
```

### 5. Create Firestore Database
```
Firebase Console → Firestore Database → Create database
Start in: Production mode
Location: Asia Southeast 1 (Singapore)
Create
```

### 6. Update Security Rules
Go to Firestore Rules tab and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      match /orders/{orderId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    match /meals/{mealId} {
      allow read: if request.auth != null;
    }
  }
}
```

Publish Rules.

### 7. Create Test User
```
Firebase Console → Authentication → Users → Create user
Email: customer@test.com
Password: Test@123456
```

### 8. Add Meals to Firestore
1. Go to Firestore Database
2. Create collection: `meals`
3. Add 4 documents (see FIREBASE_SAMPLE_DATA.json for content):
   - meal1: Ultimate Breakfast Package (₱150)
   - meal2: Lunch Value Pack (₱350)
   - meal3: Merienda Bundle (₱180)
   - meal4: Family Dinner Feast (₱499)

### 9. Create User Profile
1. In Firestore, create collection: `users`
2. Add document with ID matching Firebase Auth UID
3. Fields:
   - email: "customer@test.com"
   - displayName: "Juan Dela Cruz"
   - role: "customer"
   - address: "123 Sampaguita St., Quezon City"
   - createdAt: Timestamp(now)
   - updatedAt: Timestamp(now)

### 10. Run App
```bash
flutter pub get
flutter run
```

## Test Checklist

### Authentication
- [ ] Click "Get Started"
- [ ] Try signing up with new account
- [ ] Try logging in
- [ ] Error handling works

### Home Page
- [ ] Meals load from Firestore
- [ ] Meal cards display correctly
- [ ] Images load (or show placeholder)

### Shopping
- [ ] Add meal to cart
- [ ] See cart count badge
- [ ] Open cart
- [ ] See items in cart
- [ ] Adjust quantities

### Checkout
- [ ] Click "Proceed to Checkout"
- [ ] Fill delivery details
- [ ] Select payment method
- [ ] Click "Place Order"
- [ ] See confirmation page

### Orders
- [ ] Go to "My Orders" tab
- [ ] See newly placed order
- [ ] Click "Track Order"
- [ ] See order details

## Common Issues & Solutions

### "google-services.json not found"
```
✓ Check file exists: android/app/google-services.json
✓ Run: flutter clean
✓ Run: flutter pub get
```

### "Firestore permission denied"
```
✓ Check user is logged in
✓ Check Firestore Rules are published
✓ Check user UID matches Firestore document
```

### "Meals not showing"
```
✓ Check 'meals' collection exists
✓ Check documents have: title, price, type, etc.
✓ Check Firestore Rules allow read access
```

### "Orders not saving"
```
✓ Check user logged in
✓ Check 'users/{uid}/orders' path
✓ Check Firestore Rules allow write
✓ Check browser console for errors
```

## File Structure
```
lib/
├── services/
│   ├── auth_service.dart       (Firebase Auth)
│   └── firestore_service.dart  (Firestore operations)
├── models/
│   ├── meal_package.dart
│   ├── order.dart
│   └── cart_item.dart
├── providers/
│   ├── cart_provider.dart
│   └── orders_provider.dart
└── screens/
    ├── login_page.dart
    ├── signup_page.dart
    ├── home_page.dart
    ├── cart_page.dart
    ├── checkout_page.dart
    ├── orders_page.dart
    └── track_order_page.dart
```

## API Reference

### AuthService
```dart
// Login
await AuthService().login(email, password, UserRole.customer);

// Sign up
await AuthService().signup(
  fullName: 'Juan',
  email: 'juan@test.com',
  phone: '09171234567',
  address: '123 St.',
  password: 'Pass123!',
  confirmPassword: 'Pass123!',
  role: UserRole.customer,
);

// Get current user
final user = AuthService().currentUser;

// Logout
await AuthService().logout();
```

### FirestoreService
```dart
// Get meals
final meals = await FirestoreService().getMealPackages();

// Get user orders
final orders = await FirestoreService().getUserOrders(userId);

// Create order
await FirestoreService().createOrder(userId, order);

// Update order status
await FirestoreService().updateOrderStatus(userId, orderId, newStatus);
```

## Performance Tips

1. **Indexes**: Firebase will suggest indexes - accept them
2. **Pagination**: Implement pagination for large order lists
3. **Caching**: Use local cache before Firestore calls
4. **Lazy Loading**: Load images only when needed

## Next Steps

1. ✅ Test with sample data
2. ✅ Add real meals to database
3. ✅ Integrate payment gateway
4. ✅ Add real-time order tracking
5. ✅ Set up email notifications
6. ✅ Deploy to Google Play & App Store
