# Firebase Setup Guide for BahayKusina

## 1. Create Firebase Project

### Step 1: Go to Firebase Console
1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `BahayKusina`
4. Click "Continue"
5. Enable Google Analytics (optional)
6. Create project

### Step 2: Add Android App
1. In Firebase Console, click "Android" to add Android app
2. Package name: `com.bahaykusina.app`
3. App nickname: `BahayKusina Android`
4. Download `google-services.json`
5. Place in: `android/app/google-services.json`
6. Click "Next" and follow configuration steps

### Step 3: Add iOS App (Optional)
1. Click "iOS" to add iOS app
2. Bundle ID: `com.bahaykusina.app`
3. App nickname: `BahayKusina iOS`
4. Download `GoogleService-Info.plist`
5. Place in: `ios/Runner/GoogleService-Info.plist`

## 2. Enable Authentication Methods

1. Go to **Authentication** section in Firebase
2. Click **Sign-in method**
3. Enable:
   - ✅ Email/Password
   - ✅ Google (optional)

## 3. Create Firestore Database

1. Go to **Firestore Database** in Firebase
2. Click **Create database**
3. Start in **Production mode**
4. Choose location (Asia Southeast 1 - Singapore recommended for speed)
5. Create

## 4. Create Firestore Collections & Sample Data

### Collection: `meals`
```
meals/
├── meal1
│   ├── title: "Ultimate Breakfast Package"
│   ├── description: "Start your day right with a hearty Filipino breakfast"
│   ├── price: 150
│   ├── vendorName: "Nanay's Kitchen"
│   ├── imageUrl: "https://example.com/image1.jpg"
│   ├── type: "Breakfast"
│   └── stockLeft: 20
│
├── meal2
│   ├── title: "Lunch Value Pack"
│   ├── description: "Complete lunch meal for the whole family"
│   ├── price: 350
│   ├── vendorName: "Nanay's Kitchen"
│   ├── imageUrl: "https://example.com/image2.jpg"
│   ├── type: "Lunch"
│   └── stockLeft: 15
│
├── meal3
│   ├── title: "Merienda Bundle"
│   ├── description: "Perfect afternoon snacks for the family"
│   ├── price: 180
│   ├── vendorName: "Lola's Lutong Bahay"
│   ├── imageUrl: "https://example.com/image3.jpg"
│   ├── type: "Merienda"
│   └── stockLeft: 8
│
└── meal4
    ├── title: "Family Dinner Feast"
    ├── description: "A satisfying meal for four, ready to serve"
    ├── price: 499
    ├── vendorName: "Ate's Specialties"
    ├── imageUrl: "https://example.com/image4.jpg"
    ├── type: "Dinner"
    └── stockLeft: 12
```

### Collection: `users/{userId}/orders`
```
users/
└── user123
    └── orders/
        ├── order1
        │   ├── orderId: "#ORD-001"
        │   ├── orderDate: Timestamp(2025-01-04)
        │   ├── items: [
        │   │   {
        │   │     mealTitle: "Ultimate Breakfast Package",
        │   │     quantity: 2,
        │   │     pricePerUnit: 150
        │   │   }
        │   │ ]
        │   ├── totalAmount: 300
        │   ├── status: "outfordelivery"
        │   ├── deliveryAddress: "123 Sampaguita St., Quezon City"
        │   ├── contactNumber: "0919-345-6789"
        │   ├── paymentMethod: "Cash on Delivery"
        │   ├── riderName: "Mark Santos"
        │   └── riderEta: "15 mins"
        │
        └── order2
            ├── orderId: "#ORD-002"
            ├── orderDate: Timestamp(2025-01-03)
            ├── items: [...]
            ├── totalAmount: 350
            ├── status: "delivered"
            └── ...
```

### Collection: `users`
```
users/
└── user123
    ├── email: "juan@example.com"
    ├── displayName: "Juan Dela Cruz"
    ├── role: "customer"
    ├── address: "123 Sampaguita St., Quezon City"
    ├── createdAt: Timestamp(2024-12-15)
    └── updatedAt: Timestamp(2025-01-04)
```

## 5. Firestore Security Rules (for testing)

Go to **Firestore Database** → **Rules** and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Orders subcollection
      match /orders/{orderId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Public meal listings
    match /meals/{mealId} {
      allow read: if request.auth != null;
    }
  }
}
```

## 6. Create Test Accounts in Firebase

1. Go to **Authentication** → **Users**
2. Click **Create user**
3. Create test account:
   - Email: `customer@test.com`
   - Password: `Test@123456`
   - Role: Customer

4. Create vendor account:
   - Email: `vendor@test.com`
   - Password: `Test@123456`
   - Role: Vendor

## 7. Create Users in Firestore

1. Go to **Firestore Database**
2. Create collection: `users`
3. Add document with ID: `{copy UID from auth}`
4. Add fields:
   ```
   email: "customer@test.com"
   displayName: "Juan Dela Cruz"
   role: "customer"
   address: "123 Sampaguita St., Quezon City"
   createdAt: Timestamp(now)
   updatedAt: Timestamp(now)
   ```

## 8. Add Sample Meals

1. Create collection: `meals`
2. Add 4 documents with data from Collection Structure above
3. Use these IDs: `meal1`, `meal2`, `meal3`, `meal4`

## 9. Initialize Firebase in main.dart

The app is already configured in `main.dart` with:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BahayKusinaApp());
}
```

Run:
```bash
flutterfire configure
```

This will generate `firebase_options.dart` automatically.

## 10. Test the App Flow

### Test Sign Up (Customer)
1. Click "Get Started" on Welcome Screen
2. Click "Sign Up"
3. Enter:
   - Full Name: Juan Dela Cruz
   - Email: customer@test.com
   - Phone: 09171234567
   - Address: 123 Sampaguita St., Quezon City
   - Password: Test@123456
   - Confirm Password: Test@123456
4. Select "Order Food" role
5. Should redirect to Home Page

### Test Login
1. Click "Log In" on Login Page
2. Enter:
   - Email: customer@test.com
   - Password: Test@123456
3. Should redirect to Home Page

### Test Order Flow
1. Browse meals (from Firestore)
2. Add meal to cart
3. Go to cart
4. Click "Proceed to Checkout"
5. Fill delivery details
6. Select payment method
7. Click "Place Order - ₱XXX"
8. Should show confirmation page
9. Check "My Orders" tab - new order should appear
10. Click "Track Order" to see order details

## 11. Expected Features Working

✅ User Authentication (Firebase Auth)
✅ Meal listings (from Firestore)
✅ Add to cart
✅ Checkout and place order
✅ Orders saved to Firestore
✅ View orders in "My Orders"
✅ Track order status
✅ User profile in Firestore

## 12. Troubleshooting

### Firebase not initializing
- Run: `flutterfire configure` in project root
- Check `google-services.json` exists in `android/app/`

### Firestore permission denied
- Check Firestore Rules (step 5)
- Ensure user is authenticated

### Meals not showing
- Check `meals` collection exists in Firestore
- Ensure documents have required fields

### Orders not saving
- Check user is logged in
- Check `users/{userId}/orders` collection path
- Check Firestore Rules allow write access

## 13. Next Steps

Once tested:
1. Add image URLs for meals in Firestore
2. Implement real payment gateway (Stripe, GCash)
3. Add real-time order tracking with GPS
4. Set up email notifications for orders
5. Add admin dashboard for vendors
