# Firebase Configuration - Complete Setup Guide

## ✅ Completed

### 1. Fixed iOS Firebase Configuration
**Status:** ✅ DONE

**Changes Made:**
- Updated iOS config in `lib/firebase_options.dart`
- Changed projectId: `bahaykusina` → `bahay-kusina-main` ✓
- Updated messagingSenderId: `123456789` → `337492275214` ✓
- Fixed appId to use correct project ID pattern ✓
- Updated database URL to match Android/Web ✓
- Updated storage bucket to match ✓
- Added authDomain for consistency ✓

**Result:** All three platforms (Android, iOS, Web) now point to `bahay-kusina-main`

---

## 📋 Required Firebase Console Tasks

### Task 1: Deploy Firestore Security Rules

**Location:** Firebase Console → bahay-kusina-main → Firestore Database → Rules

**Step-by-Step:**
1. Open https://console.firebase.google.com
2. Select "bahay-kusina-main" project
3. Go to "Firestore Database" 
4. Click "Rules" tab
5. Delete current rules
6. Copy-paste the following rules:

```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
    
    // Meals collection - everyone can read, vendors can write their own
    match /meals/{mealId} {
      allow read: if true;
      allow create: if request.auth.uid != null && 
                       request.resource.data.vendorId == request.auth.uid;
      allow update, delete: if request.auth.uid == resource.data.vendorId;
    }
    
    // Orders - customers can create, vendors/customers can read their orders
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.vendorId || 
                     request.auth.uid == resource.data.customerId;
      allow create: if request.auth.uid != null &&
                       request.resource.data.customerId == request.auth.uid;
      allow update: if request.auth.uid == resource.data.vendorId;
      allow delete: if request.auth.uid == resource.data.vendorId &&
                       resource.data.status in ['pending', 'cancelled'];
    }
    
    // Orders subcollection in users
    match /users/{userId}/orders/{orderId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Messages collection for chat
    match /messages/{messageId} {
      allow read, write: if request.auth.uid != null;
    }
    
    // Deny everything else by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

7. Click "Publish"

**Verify Success:**
- Rules should deploy without errors
- Tab title should change from "Rules (⚠️)" to "Rules"

---

### Task 2: Create Firestore Indexes

**Location:** Firebase Console → bahay-kusina-main → Firestore Database → Indexes

**Note:** Firestore may auto-create indexes when you use compound queries. But it's better to create them upfront.

**Step-by-Step:**
1. Go to Firestore Database → Indexes
2. Click "Create Index"
3. Create these indexes:

**Index 1: Orders by Vendor & Status**
- Collection: `orders`
- Field 1: `vendorId` (Ascending)
- Field 2: `status` (Ascending)
- Query scope: Collection

**Index 2: Orders by Date**
- Collection: `orders`
- Field 1: `orderDate` (Descending)
- Query scope: Collection

**Index 3: Meals by Vendor**
- Collection: `meals`
- Field 1: `vendorId` (Ascending)
- Field 2: `updatedAt` (Descending)
- Query scope: Collection

**Index 4: Orders by Customer**
- Collection: `orders`
- Field 1: `customerId` (Ascending)
- Field 2: `orderDate` (Descending)
- Query scope: Collection

**Expected Result:**
All 4 indexes should show "Enabled" status after ~2-5 minutes

---

### Task 3: Update Firebase Storage Rules

**Location:** Firebase Console → Storage → Rules

**Step-by-Step:**
1. Go to Storage
2. Click "Rules" tab
3. Replace rules with:

```
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // Meal images - vendors can upload/delete their own
    match /meals/{vendorId}/{mealId}/{allFiles=**} {
      allow read: if true;
      allow create: if request.auth.uid == vendorId;
      allow delete: if request.auth.uid == vendorId;
    }
    
    // User profile images
    match /users/{userId}/profile/{fileName} {
      allow read: if true;
      allow create, update, delete: if request.auth.uid == userId;
    }
    
    // Order receipts - vendor and customer only
    match /orders/{orderId}/{fileName} {
      allow read: if request.auth.uid != null;
      allow create: if request.auth.uid != null;
      allow delete: if false;
    }
    
    // Deny everything else
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

4. Click "Publish"

---

## 🧪 Testing & Verification

### Test 1: Verify Android/Web Connection (MOST IMPORTANT)
```
1. Run: flutter run -d chrome
2. Go to Vendor Dashboard
3. Try to add a package
4. Check Firestore console - should see new meal in meals collection
5. Go to Customer Home
6. Verify you see the new package
```

### Test 2: Verify Real-Time Streams
```
1. Open Chrome DevTools → Application → Local Storage
2. Look for meal data in cache
3. Add a package while app is running
4. Check that meal appears without page refresh
5. Check that notification shows up
```

### Test 3: Security Rules Work
```
1. In Firestore console, go to Rules Playground
2. Test read access to meals (should succeed without auth)
3. Test create access to meals (should fail without auth)
4. Test read access to other user's orders (should fail)
5. Test vendor can update own order (should succeed if vendorId matches)
```

### Test 4: Images Upload & Serve
```
1. Add package with image
2. Check Storage console - image should appear under meals/{vendorId}/
3. Verify image displays correctly in app
4. Test image works offline (might show cached version)
```

---

## 📊 Database Schema Verification

### Run this to check data types:

**In Firestore Console:**

1. **meals collection:** Click any document
   - ✓ `price` should be Number (not string)
   - ✓ `left` should be Number
   - ✓ `createdAt` should be Timestamp (not string)
   - ✓ `vendorId` should be string matching user ID

2. **orders collection:** Click any document
   - ✓ `totalAmount` should be Number
   - ✓ `orderDate` should be Timestamp
   - ✓ `vendorId` should be string
   - ✓ `customerId` should be string
   - ✓ `items` should be Array of objects

3. **users collection:** Click any document
   - ✓ `userId` should match document ID
   - ✓ `email` should be string
   - ✓ `createdAt` should be Timestamp

**Fix any string/number mismatches:**
If you find `price: "100"` instead of `price: 100`:
1. Edit document
2. Change field from string to number
3. This is important for calculations

---

## 🔧 Code Configuration Check

### Verify in `lib/services/firestore_service.dart`:

✓ All collection names match: `meals`, `orders`, `users`
✓ All field names match database: `vendorId`, `customerId`, `orderDate`, etc.
✓ Retry logic is implemented
✓ Timeout protection (10s) is in place
✓ Real-time streams use `.snapshots()` not polling

---

## 🚀 Performance Optimization

### Current Implementation (Already Done)
✅ 5-minute caching for meals/orders
✅ Real-time streams (no polling)
✅ Fallback data for offline mode
✅ Sequential loading (orders → meals)
✅ Timeout protection (10s fetch, 60s upload)

### Optional Enhancements

**Enhancement 1: Add pagination for large lists**
```dart
// In firestore_service.dart - add after getMealPackages()
Future<List<Meal>> getMealPackagesByVendor(String vendorId, 
    {int limit = 20, DocumentSnapshot? lastDoc}) async {
  Query query = _firestore
      .collection('meals')
      .where('vendorId', isEqualTo: vendorId)
      .orderBy('createdAt', descending: true)
      .limit(limit);
  
  if (lastDoc != null) {
    query = query.startAfterDocument(lastDoc);
  }
  
  final snapshot = await query.get();
  return snapshot.docs.map((doc) => Meal.fromDocument(doc)).toList();
}
```

**Enhancement 2: Denormalize vendor name in orders**
```dart
// In createOrder() - add this field:
'vendorName': vendorDoc.get('fullName'), // Cache vendor name
'vendorImageUrl': vendorDoc.get('profileImageUrl'),
```
This prevents needing to fetch vendor data separately.

**Enhancement 3: Archive old orders**
```dart
// Run monthly - archives orders older than 2 years
Future<void> archiveOldOrders() async {
  final twoYearsAgo = DateTime.now().subtract(Duration(days: 730));
  
  final snapshot = await _firestore
      .collection('orders')
      .where('orderDate', isLessThan: Timestamp.fromDate(twoYearsAgo))
      .get();
  
  final batch = _firestore.batch();
  for (var doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();
}
```

---

## 📞 Support References

| Issue | Solution |
|-------|----------|
| "Permission denied" error | Check Firestore Rules are deployed |
| Slow queries | Create missing Firestore Indexes |
| Images not uploading | Check Storage Rules and permissions |
| Real-time updates not working | Verify streams are started in UI |
| iOS app crashes | Verify iOS config uses bahay-kusina-main |
| Android data different from Web | Check all three configs use same project |
| Orders not syncing | Check network, verify batch writes succeed |

---

## ✅ Final Checklist

Before going live, verify:

- [ ] iOS config fixed (uses bahay-kusina-main)
- [ ] Firestore security rules deployed
- [ ] Firestore indexes created (4 total)
- [ ] Storage rules updated
- [ ] Tested adding package on Web
- [ ] Tested order creation
- [ ] Tested real-time notifications
- [ ] Verified data appears in correct collections
- [ ] Checked all field types are correct (number, not string)
- [ ] Images upload and serve correctly
- [ ] App works offline with fallback data
- [ ] No console errors in DevTools

---

## 🎯 Immediate Actions Required

1. **TODAY:**
   - ✅ iOS Firebase config fixed
   - [ ] Deploy Firestore security rules
   - [ ] Create Firestore indexes

2. **THIS WEEK:**
   - [ ] Update Storage rules
   - [ ] Test all features on Web, Android, iOS
   - [ ] Verify real-time notifications work

3. **ONGOING:**
   - [ ] Monitor Firebase usage/costs
   - [ ] Archive orders monthly
   - [ ] Review security rules quarterly

