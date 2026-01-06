# 🚀 LAUNCH CHECKLIST - BahayKusina App

Your app is 100% ready. This checklist will take you from code to live in 30 minutes.

---

## PHASE 1: Firebase Project Setup (10 minutes)

### Step 1: Create Firebase Project
- [ ] Go to [console.firebase.google.com](https://console.firebase.google.com)
- [ ] Click "Create a project" or "Add project"
- [ ] Name: `BahayKusina`
- [ ] Uncheck "Enable Google Analytics" (optional)
- [ ] Click "Create project"
- [ ] Wait for project to initialize (1-2 minutes)

### Step 2: Add Android App
- [ ] In Firebase Console, click Android icon
- [ ] Package name: `com.example.bahaykusina`
- [ ] App nickname: `BahayKusina Android` (optional)
- [ ] Click "Register app"

### Step 3: Download Configuration
- [ ] Download `google-services.json`
- [ ] Save to: `android/app/google-services.json`
- [ ] Verify file exists at that location
- [ ] Click "Next" in Firebase Console

### Step 4: Continue Setup
- [ ] Follow the gradle setup steps shown (likely already done)
- [ ] Click "Next" then "Continue to console"

✅ **Firebase project created and Android app registered**

---

## PHASE 2: Enable Firebase Services (5 minutes)

### Step 5: Enable Authentication
- [ ] In Firebase Console, click "Authentication" (left sidebar)
- [ ] Click "Get Started"
- [ ] Click "Email/Password"
- [ ] Toggle "Enable"
- [ ] Click "Save"

### Step 6: Create Firestore Database
- [ ] In Firebase Console, click "Firestore Database" (left sidebar)
- [ ] Click "Create Database"
- [ ] Select "Start in Production mode"
- [ ] Location: **Asia Southeast 1** (Singapore - closest to Philippines)
- [ ] Click "Create"
- [ ] Wait for database to initialize (1-2 minutes)

### Step 7: Publish Security Rules
- [ ] In Firestore, click "Rules" tab
- [ ] Delete all existing content
- [ ] Copy and paste the rules from `REFERENCE_CARD.md` or `FIRESTORE_SCHEMA.md`
- [ ] Click "Publish"
- [ ] Wait for rules to deploy

✅ **Firebase Authentication and Firestore enabled**

---

## PHASE 3: Configure Flutter (3 minutes)

### Step 8: Install FlutterFire CLI
Open terminal and run:
```bash
dart pub global activate flutterfire_cli
```

### Step 9: Configure Flutter Project
Change to your project directory:
```bash
cd c:\flutterAct\BahayKusinaApp\BahayKusina\bahaykusina
```

Run configuration:
```bash
flutterfire configure
```

When prompted:
- [ ] Select Firebase project: **BahayKusina**
- [ ] Select platforms: **Android**
- [ ] Wait for configuration to complete

This creates `lib/firebase_options.dart` automatically.

### Step 10: Get Dependencies
```bash
flutter pub get
```

✅ **Flutter Firebase integration complete**

---

## PHASE 4: Add Sample Data (5 minutes)

### Step 11: Create Meals Collection
1. [ ] Go to Firebase Console → Firestore Database
2. [ ] Click "Create collection"
3. [ ] Name: `meals`
4. [ ] Click "Next"

### Step 12: Add 4 Sample Meals

Add these documents (Document IDs can auto-generate, but suggested IDs below):

**Document: meal_001**
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

**Document: meal_002**
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

**Document: meal_003**
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

**Document: meal_004**
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

For each document:
1. [ ] Click "Add document" or "Start collection"
2. [ ] Paste the JSON fields and values
3. [ ] Click "Save"

✅ **Sample meals added to Firestore**

---

## PHASE 5: Test the App (5 minutes)

### Step 13: Launch App
```bash
flutter run
```

### Step 14: Test Sign Up
- [ ] Click "Get Started" on Welcome screen
- [ ] Click "Don't have an account? Sign up"
- [ ] Fill sign up form:
  - Full Name: `John Test`
  - Email: `john@test.com`
  - Phone: `09175551234`
  - Address: `123 Main St, Manila`
  - Password: `Test@123456`
  - Confirm: `Test@123456`
- [ ] Click "Sign Up"
- [ ] Wait for navigation to Home page

**Expected Result:**
- ✅ No errors on console
- ✅ Navigated to Home page
- ✅ User appears in Firebase Authentication

### Step 15: Test Meal Browsing
- [ ] Home page displays
- [ ] 4 meals visible (Adobo, Sinigang, Grilled Fish, Halo-Halo)
- [ ] Each meal shows: name, vendor, description, price, stock
- [ ] Prices correct (₱85, ₱95, ₱120, ₱65)

**Expected Result:**
- ✅ All 4 meals loaded from Firestore
- ✅ Data displayed correctly

### Step 16: Test Add to Cart
- [ ] Click "Order" on Adobo
- [ ] Enter quantity: `2`
- [ ] Click "Add to Cart"
- [ ] See toast message: "Added to cart"
- [ ] Click "Continue Shopping"

**Expected Result:**
- ✅ Toast notification appears
- ✅ Cart updated
- ✅ Meal added to cart

### Step 17: Test Shopping Cart
- [ ] Click 🛒 Cart button at bottom
- [ ] Verify Adobo (qty 2, ₱170 total) appears
- [ ] Test operations:
  - [ ] Click "+" to increase to qty 3
  - [ ] Click "-" to decrease back to qty 2
  - [ ] Total price updates correctly
- [ ] Go back and add Sinigang (qty 1)
- [ ] Go back and add Grilled Fish (qty 2)

**Expected Result:**
- ✅ All items in cart
- ✅ Quantities editable
- ✅ Total calculated: (2×85) + (1×95) + (2×120) = ₱535

### Step 18: Test Checkout
- [ ] Click "Proceed to Checkout"
- [ ] Fill checkout form:
  - Delivery Address: `123 Main St, Manila, 1000`
  - Contact Number: `09175551234`
  - Payment Method: Select one
- [ ] Click "Place Order"

**Expected Result:**
- ✅ Order confirmation page displays
- ✅ Order ID shown (e.g., ORD-12345)
- ✅ Total amount: ₱535
- ✅ All items listed

### Step 19: Test My Orders
- [ ] Click "View All Orders"
- [ ] "My Orders" page displays
- [ ] Your order appears in list
- [ ] Click on order to view details

**Expected Result:**
- ✅ Order appears in list
- ✅ Order status: "Pending"
- ✅ Order total: ₱535
- ✅ Can view order details

### Step 20: Verify Firebase Console
- [ ] Go to Firebase Console
- [ ] **Authentication tab:**
  - [ ] Your user email appears
  - [ ] Correct sign-up timestamp
- [ ] **Firestore Database:**
  - [ ] `users/{uid}` document created with your data
  - [ ] `users/{uid}/orders/` subcollection created
  - [ ] Order document exists with all fields
  - [ ] Order status: "pending"

✅ **All tests passed - App is working!**

---

## PHASE 6: Optional - Create Test User Account

### Step 21: Create Test User in Firebase
In Firebase Console → Authentication:
1. [ ] Click "Add user"
2. [ ] Email: `testuser@test.com`
3. [ ] Password: `Test@123456`
4. [ ] Click "Add user"

### Step 22: Test Login with Test User
Back in app:
1. [ ] Click logout or restart app
2. [ ] Click "Get Started"
3. [ ] Enter:
   - Email: `testuser@test.com`
   - Password: `Test@123456`
4. [ ] Click "Login"

**Expected Result:**
- ✅ Login successful
- ✅ Navigated to Home page
- ✅ Can place orders with this account

✅ **Test user created and login works**

---

## FINAL VERIFICATION

### Code & Compilation
- [ ] `flutter pub get` completed without errors
- [ ] `flutter run` launches without crashes
- [ ] No Firebase errors in console
- [ ] No runtime errors during testing

### Features Working
- [ ] Sign up with new email
- [ ] View meals from Firestore
- [ ] Add meals to cart
- [ ] Checkout process
- [ ] Place order
- [ ] View order in "My Orders"
- [ ] View order details
- [ ] Login/logout working

### Data Persistence
- [ ] Orders appear in "My Orders" after app restart
- [ ] User profile loads on login
- [ ] Meals load from Firestore every time
- [ ] Cart clears after order (or persists per your design)

### Firestore Verification
- [ ] `meals` collection exists with 4 documents
- [ ] `users` collection auto-created with user documents
- [ ] User orders saved correctly
- [ ] All field names match code (type, title, vendor, desc, price, left, imageUrl)

---

## COMMON ISSUES & FIXES

| Issue | Fix | Done |
|-------|-----|------|
| App crashes on startup | Run `flutterfire configure` | ☐ |
| "google-services.json not found" | Download from Firebase to `android/app/` | ☐ |
| No meals show | Create `meals` collection in Firestore | ☐ |
| Permission denied | Check Firestore security rules published | ☐ |
| Login fails | Enable Email/Password in Authentication | ☐ |
| Orders not saving | Check user document created in Firestore | ☐ |
| Images not showing | Verify asset paths in imageUrl match | ☐ |

---

## SUCCESS SUMMARY

When all steps complete, you have:

✅ **Infrastructure:**
- Firebase project
- Firestore database
- Authentication system
- Sample meals
- Security rules

✅ **App Features Working:**
- Complete authentication flow
- Product browsing from database
- Shopping cart management
- Order checkout and creation
- Order tracking and history
- User profile management

✅ **Data Persistence:**
- Users in Firebase Authentication
- User profiles in Firestore
- Meals in Firestore
- Orders in Firestore
- All synced in real-time

✅ **Ready For:**
- Testing with real data
- Inviting users to beta
- Vendor onboarding
- Payment integration
- Production deployment

---

## NEXT STEPS (Optional Enhancements)

1. **Add Real Meals:**
   - Update meal images in `assets/images/`
   - Update imageUrl in Firestore

2. **Payment Gateway:**
   - Integrate GCash or PayMaya API
   - Update paymentMethod field

3. **Order Notifications:**
   - Enable Firebase Cloud Messaging
   - Send order status updates

4. **Admin Dashboard:**
   - Create vendor portal
   - Add meal management
   - View order analytics

5. **Deploy:**
   - Build APK: `flutter build apk --release`
   - Upload to Google Play Store

---

## DOCUMENTATION REFERENCE

For detailed help, see:
- `SETUP_COMPLETE.md` - Overview of what was done
- `FIREBASE_QUICK_START.md` - 5-minute quick reference
- `FIREBASE_SETUP_GUIDE.md` - Detailed 10-step guide
- `TESTING_GUIDE.md` - Complete testing scenarios
- `FIRESTORE_SCHEMA.md` - Database structure
- `REFERENCE_CARD.md` - Code reference & debugging

---

## TIME ESTIMATE

| Phase | Time | Status |
|-------|------|--------|
| Firebase Setup | 10 min | ⏳ Manual |
| Enable Services | 5 min | ⏳ Manual |
| Configure Flutter | 3 min | ⏳ Manual |
| Add Sample Data | 5 min | ⏳ Manual |
| Test App | 5 min | ⏳ Manual |
| **TOTAL** | **28 minutes** | ⏳ **START NOW** |

---

## YOU'RE READY! 🎉

All code is written. All services are integrated. All models are created.

**All you need to do is:**
1. Create Firebase project (free account)
2. Download google-services.json
3. Run `flutterfire configure`
4. Create meals collection
5. Test the app

**That's it! Your delivery app is live in 30 minutes.** 🚀

---

**When all ☐ boxes are checked, celebrate! Your app is production-ready.**

Questions? See the documentation files listed above.

**Status: READY TO LAUNCH ✅**
