# BahayKusina App - Complete Testing Guide

Your app is now fully integrated with Firebase! Follow this guide to test all features.

## Pre-Test Checklist

Before you start, make sure:
- ✅ Firebase project created at [console.firebase.google.com](https://console.firebase.google.com)
- ✅ `google-services.json` placed in `android/app/`
- ✅ `flutterfire configure` executed (creates `lib/firebase_options.dart`)
- ✅ Authentication enabled (Email/Password)
- ✅ Firestore database created with collections:
  - `meals` (with 4 sample meals)
  - `users` (created automatically when users sign up)
- ✅ Firestore security rules published

## Step 1: Launch App

```bash
cd c:\flutterAct\BahayKusinaApp\BahayKusina\bahaykusina
flutter pub get
flutter run
```

**Expected Result:**
- App starts without Firebase errors
- Welcome screen displays

## Step 2: Test Authentication - Sign Up

1. Click **"Don't have an account? Sign up here"** on Welcome screen
2. Enter:
   - Full Name: `John Doe`
   - Email: `john@test.com`
   - Phone: `09175551234`
   - Address: `123 Main St, Manila`
   - Password: `Test@123456`
   - Confirm Password: `Test@123456`
3. Click **"Sign Up"**

**Expected Result:**
- User created in Firebase Authentication
- User profile saved in Firestore (`users/{uid}` collection)
- Redirected to Home Page
- No error messages

### Test Alternative: Login with Pre-Created User

If you created test users in Firebase:
1. On Welcome screen, click **"Get Started"**
2. Enter:
   - Email: `customer@test.com`
   - Password: `Test@123456`
3. Click **"Login"**

**Expected Result:**
- Login successful
- Redirected to Home Page
- User preferences loaded from Firestore

## Step 3: Test Home Page & Meal Browsing

1. You should now see **Home Page** with meals
2. Scroll and observe:
   - Adobo with Rice (₱85)
   - Sinigang na Baboy (₱95)
   - Grilled Fish (₱120)
   - Halo-Halo (₱65)

**Expected Result:**
- Meals load from Firestore `meals` collection
- Images display (if assets exist)
- Vendor names and descriptions visible
- Prices and stock quantities accurate

## Step 4: Test Adding to Cart

1. Click **"Order"** button on any meal
2. In the popup:
   - Enter quantity: `2`
   - Click **"Add to Cart"**
3. A toast notification appears: "Added to cart"
4. Click **"Continue Shopping"**

**Expected Result:**
- Meal added to shopping cart
- Cart quantity updates (visible in cart icon)
- Multiple items can be added
- Can add same item multiple times (increases quantity)

## Step 5: Test Shopping Cart

1. Click the **"🛒 Cart"** button at bottom
2. Verify:
   - All added items listed
   - Quantities correct
   - Prices calculated
   - Total amount shown

**Test Cart Operations:**

### Increase Quantity
1. Click **"+"** button next to item
2. Quantity increases
3. Total price updates

**Expected Result:** Quantity increases by 1, total updates

### Decrease Quantity
1. Click **"-"** button next to item
2. If quantity becomes 0, item removed

**Expected Result:** Quantity decreases, item removed if 0

### Remove Item
1. Click **"✕"** or trash icon
2. Item removed immediately

**Expected Result:** Item removed, cart total updates

## Step 6: Test Checkout

1. In Cart page, click **"Proceed to Checkout"**
2. Fill in Delivery Details:
   - Delivery Address: `123 Main St, Manila, 1000`
   - Contact Number: `09175551234`
   - Payment Method: Select one option
   - Optional: Rider name / ETA
3. Click **"Place Order"**

**Expected Result:**
- Order saved to Firestore (`users/{uid}/orders`)
- Confirmation page displays:
  - Order ID (e.g., `ORD-12345`)
  - Order date
  - Items list
  - Total amount
  - Delivery address
- Order status: `Pending`

## Step 7: Test Order Confirmation

1. On confirmation page, observe:
   - Order number displayed
   - All items listed
   - Total price correct
   - Estimated delivery time
2. Click **"View All Orders"**

**Expected Result:**
- Navigated to "My Orders" page
- Newly created order appears in list
- Order status shows as "Pending"

## Step 8: Test My Orders Page

1. Click **"My Orders"** tab at bottom
2. View all placed orders:
   - Order ID
   - Order date
   - Total amount
   - Current status
   - Delivery address

**Test Order Details:**
1. Click on any order
2. Verify Order Details page shows:
   - Order ID
   - Items with quantities
   - Subtotal
   - Delivery address
   - Contact number
   - Payment method
   - Rider info (if assigned)
   - Order status with tracking

**Expected Result:**
- All orders loaded from Firestore
- Correct information displayed
- Can view each order's details
- Status updates reflect Firestore data

## Step 9: Test Order Status Tracking

1. On Order Details page, check:
   - Status badge (Pending, Out for Delivery, Delivered, Cancelled)
   - Rider name (if assigned)
   - Rider ETA (if assigned)
   - Timeline of order progression

**Expected Result:**
- Order status displays correctly
- Delivery information visible
- Can understand order progress

## Step 10: Test Profile/Account

1. Click account icon or menu
2. View profile information:
   - Email
   - Full name
   - Phone
   - Address
3. (Optional) Add logout button to test

**Expected Result:**
- Profile information loaded from Firestore
- All user details correct

## Full Test Scenario

### Complete User Journey (15 minutes)

1. **Sign Up**: Create new user account
   - Time: 2 min
   - Verify user created in Firebase Auth
   - Verify profile in Firestore

2. **Browse Meals**: View available meals
   - Time: 2 min
   - Check all 4 meals load from Firestore
   - Verify meal details accurate

3. **Build Cart**: Add 3 different meals
   - Time: 3 min
   - Add Adobo (qty 2), Sinigang (qty 1), Grilled Fish (qty 3)
   - Verify cart total: (2×85) + (1×95) + (3×120) = ₱665

4. **Checkout**: Place order
   - Time: 3 min
   - Fill delivery details
   - Place order
   - Verify confirmation page

5. **View Orders**: Check My Orders list
   - Time: 2 min
   - Verify new order appears
   - Verify order amount matches
   - Verify order status is "Pending"

6. **Check Details**: Review order details
   - Time: 2 min
   - Verify all items listed
   - Verify delivery address correct
   - Verify order status

7. **Logout & Login**: Test persistence
   - Time: 1 min
   - Logout from app
   - Login again with same credentials
   - Verify orders still appear
   - Verify user data persists

## Firebase Console Verification

While testing, verify in Firebase Console:

### Authentication Tab
- [ ] New user appears after sign up
- [ ] User email and creation date correct
- [ ] User authentication enabled

### Firestore Database

**Users Collection:**
- [ ] Collection `users` created
- [ ] Document created with user ID (same as Firebase Auth UID)
- [ ] Fields: email, displayName, role, createdAt, updatedAt

**Meals Collection:**
- [ ] Collection `meals` exists with 4 documents
- [ ] Each meal has: type, title, vendor, desc, price, left, imageUrl
- [ ] All meals readable from app

**Orders:**
- [ ] Path: `users/{uid}/orders/`
- [ ] Document created after placing order
- [ ] Fields: orderId, orderDate, items[], totalAmount, status, etc.
- [ ] Status is "pending"

## Common Test Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| App crashes on startup | Firebase not initialized | Run `flutterfire configure` |
| "Permission denied" creating order | Security rules issue | Check Firestore Rules are published |
| No meals appear | `meals` collection missing | Create `meals` collection in Firestore |
| Meals show but no images | Image assets missing | Add images to `assets/images/` folder |
| Orders not appearing in "My Orders" | OrdersProvider not updated | Restart app or hot reload |
| Prices calculated wrong | Data type mismatch | Verify meal prices are numbers in Firestore |
| Can't checkout | Cart empty or validation error | Add items to cart first, fill all fields |
| User data not persisting | Firestore rules blocking reads | Check security rules |

## Performance Testing

**Load Times (Should be < 2 seconds):**
- [ ] Home page loads meals (< 2s)
- [ ] My Orders loads orders (< 2s)
- [ ] Order details loads (< 1s)

**Data Accuracy:**
- [ ] Prices match Firestore exactly
- [ ] Item quantities preserved
- [ ] Order totals calculated correctly
- [ ] User information always current

## Edge Cases to Test

### Low Stock
1. Add meal with only 2 items left
2. Order it with quantity 3
3. Note: App doesn't prevent overstocking (can add feature later)

### Multiple Orders
1. Place 5 orders with different items
2. Verify all appear in My Orders
3. Verify ordered by date (newest first)

### Large Cart
1. Add 10 items to cart
2. Verify app doesn't lag
3. Verify total calculated correctly

### Long Order Details
1. Order with 10 items
2. Verify all items display correctly
3. Verify scroll works smoothly

## Final Verification Checklist

✅ App compiles and runs without errors
✅ Firebase authentication working (sign up & login)
✅ Meals load from Firestore
✅ Shopping cart functions (add, remove, update qty)
✅ Checkout process works end-to-end
✅ Orders saved to Firestore
✅ Orders appear in My Orders page
✅ Order details display correctly
✅ User profile information persists
✅ No console errors during normal usage

## Next Steps After Testing

1. **Fix Mock Data Issues:**
   - Update OrderConfirmationPage to use real order data
   - Implement real order ID generation

2. **Add Features:**
   - Order status updates from admin panel
   - Real-time order notifications
   - Order cancellation
   - Payment gateway integration

3. **Optimize:**
   - Add meal search/filter
   - Implement meal categories
   - Add restaurant/vendor profiles
   - Review and rating system

4. **Deploy:**
   - Build APK for testing: `flutter build apk --release`
   - Upload to Google Play Store (requires developer account)

## Support Resources

- [FirebaseAuth Documentation](https://firebase.flutter.dev/docs/auth/overview)
- [Cloud Firestore Guide](https://firebase.google.com/docs/firestore)
- [FlutterFire Docs](https://firebase.flutter.dev/)
- [Flutter Docs](https://flutter.dev/docs)

---

**Questions?** Refer to [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md) for detailed setup instructions.
