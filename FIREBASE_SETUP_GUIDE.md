# Firebase Setup Guide for BahayKusina App

Complete step-by-step guide to set up Firebase and Firestore for your Flutter app.

## Prerequisites

- Flutter SDK installed
- VS Code or Android Studio
- Google account
- `flutterfire` CLI installed (install with: `dart pub global activate flutterfire_cli`)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"** or **"Add project"**
3. Enter project name: `BahayKusina`
4. Accept Google Analytics settings (optional)
5. Click **"Create project"** and wait for it to initialize

## Step 2: Set Up Android Configuration

### 2.1 Get google-services.json

1. In Firebase Console, click the Android icon or **"Add app"**
2. Select **"Android"**
3. Fill in:
   - Package name: `com.example.bahaykusina`
   - App nickname: `BahayKusina Android`
4. Download `google-services.json`
5. Copy it to: `android/app/google-services.json`

### 2.2 Configure Gradle

The app is already configured. Verify these files:

**android/build.gradle.kts** should have:
```kotlin
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

**android/app/build.gradle.kts** should have:
```kotlin
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.firebase:firebase-analytics'
}
```

## Step 3: Configure Flutter Project

Run this command from your project root:

```bash
flutterfire configure
```

This will:
- Ask you to select your Firebase project (select `BahayKusina`)
- Ask which platforms (select `android`)
- Create `lib/firebase_options.dart` automatically
- Update your `pubspec.yaml` dependencies

## Step 4: Update main.dart

Your `main.dart` needs Firebase initialization. It should look like:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

**Note:** This is likely already done if you ran `flutterfire configure`.

## Step 5: Enable Firebase Authentication

1. In Firebase Console, go to **Authentication** (left sidebar)
2. Click **"Get Started"**
3. Select **Email/Password** provider
4. Toggle **"Enable"** on
5. Click **"Save"**

## Step 6: Create Firestore Database

1. In Firebase Console, go to **Firestore Database** (left sidebar)
2. Click **"Create Database"**
3. Select **"Start in production mode"**
4. Choose region: **Asia Southeast 1 (Singapore)** (closest to Philippines)
5. Click **"Create"** and wait for initialization

## Step 7: Set Firestore Security Rules

1. In Firestore, go to the **"Rules"** tab
2. Replace all content with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Allow orders subcollection
      match /orders/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Allow anyone to read meals
    match /meals/{document=**} {
      allow read: if true;
      allow write: if request.auth.uid != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'vendor';
    }
  }
}
```

3. Click **"Publish"**

## Step 8: Create Firestore Collections

### 8.1 Meals Collection

1. In Firestore, click **"Create collection"**
2. Name it: `meals`
3. Click **"Next"**
4. Add these documents:

**Document ID:** `meal_001`
```json
{
  "type": "Breakfast",
  "title": "Adobo with Rice",
  "vendor": "HomeCooked Kitchen",
  "desc": "Savory pork adobo served with jasmine rice",
  "price": 85,
  "left": 15,
  "imageUrl": "assets/images/adobo.jpg"
}
```

**Document ID:** `meal_002`
```json
{
  "type": "Lunch",
  "title": "Sinigang na Baboy",
  "vendor": "Kusina Fresh",
  "desc": "Tamarind-based pork stew with vegetables",
  "price": 95,
  "left": 20,
  "imageUrl": "assets/images/sinigang.jpg"
}
```

**Document ID:** `meal_003`
```json
{
  "type": "Dinner",
  "title": "Grilled Fish",
  "vendor": "Seaside Grill",
  "desc": "Fresh grilled tilapia with lemon and herbs",
  "price": 120,
  "left": 10,
  "imageUrl": "assets/images/grilled_fish.jpg"
}
```

**Document ID:** `meal_004`
```json
{
  "type": "Dessert",
  "title": "Halo-Halo",
  "vendor": "Sweet Treats Café",
  "desc": "Traditional Filipino iced dessert with toppings",
  "price": 65,
  "left": 25,
  "imageUrl": "assets/images/halo_halo.jpg"
}
```

### 8.2 Users Collection (Manual Creation)

Users are created automatically when they sign up. But you can add test users manually:

1. In Firestore, click **"Create collection"**
2. Name it: `users`
3. Click **"Next"**
4. Add test user documents:

**Document ID:** `test_customer_uid` (use a real Firebase auth UID)
```json
{
  "email": "customer@test.com",
  "displayName": "John Customer",
  "role": "customer",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

## Step 9: Create Test Firebase Auth Users

1. In Firebase Console, go to **Authentication**
2. Go to **"Users"** tab
3. Click **"Add user"**
4. Add test accounts:

### Test Customer
- Email: `customer@test.com`
- Password: `Test@123456`

### Test Vendor
- Email: `vendor@test.com`
- Password: `Test@123456`

Then manually add their profiles in Firestore users collection.

## Step 10: Test the App

1. Save all files
2. Run the app:
   ```bash
   flutter pub get
   flutter run
   ```

3. Test flow:
   - Click **"Get Started"**
   - Sign up with a new email and password
   - Verify email in Firebase Console (Authentication > Users)
   - Browse meals from Firestore
   - Add meals to cart
   - Proceed to checkout
   - Place order (saved to Firestore)
   - View order in "My Orders" page

## Troubleshooting

### Issue: "firebase_core_web not found"
**Solution:** Run `flutter pub get` and `flutterfire configure` again

### Issue: "No document found" when fetching meals
**Solution:** Verify meals are in Firestore `meals` collection with correct field names:
- `type` (not `category`)
- `title` (not `name`)
- `vendor` (not `vendorName`)
- `desc` (not `description`)
- `price` (number)
- `left` (not `stockLeft`, number)
- `imageUrl`

### Issue: "Permission denied" when creating order
**Solution:** Check Firestore security rules are published correctly

### Issue: "google-services.json not found"
**Solution:** 
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Rebuild: `flutter clean && flutter pub get && flutter run`

## Next Steps

1. **Upload real images:**
   - Add meal images to `assets/images/`
   - Update `imageUrl` in Firestore documents

2. **Add payment gateway:**
   - Integrate GCash or PayMaya
   - Update checkout payment method

3. **Add notifications:**
   - Implement Firebase Cloud Messaging (FCM)
   - Notify users of order updates

4. **Deploy:**
   - Build APK: `flutter build apk`
   - Release on Google Play Store

## Quick Reference

| Resource | Location |
|----------|----------|
| Firebase Console | https://console.firebase.google.com |
| Firestore Database | Firebase Console > Firestore Database |
| Authentication | Firebase Console > Authentication |
| Service Account Key | Firebase Console > Project Settings > Service Accounts |
| google-services.json | `android/app/google-services.json` |
| firebase_options.dart | `lib/firebase_options.dart` (auto-generated) |

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Cloud Firestore Guide](https://firebase.google.com/docs/firestore)
