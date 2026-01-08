# Firebase & Database Analysis & Corrections

## 🔍 Current Database Structure Analysis

### Collections Identified

```
bahay-kusina-main (Main Project)
├── meals/
│   ├── {mealId}
│   │   ├── id: string
│   │   ├── type: string (Breakfast, Lunch, Dinner, Merienda, Dessert)
│   │   ├── title: string
│   │   ├── vendor: string
│   │   ├── vendorId: string
│   │   ├── desc: string
│   │   ├── price: integer
│   │   ├── left: integer (stock)
│   │   ├── imageUrl: string
│   │   ├── createdAt: timestamp
│   │   └── updatedAt: timestamp
│
├── orders/
│   ├── {orderId}
│   │   ├── orderId: string
│   │   ├── orderDate: timestamp
│   │   ├── items: array
│   │   │   └── {mealTitle, quantity, pricePerUnit}
│   │   ├── totalAmount: integer
│   │   ├── status: string (pending, confirmed, preparing, outfordelivery, delivered, cancelled)
│   │   ├── vendorId: string
│   │   ├── vendorName: string
│   │   ├── customerName: string
│   │   ├── customerId: string
│   │   ├── deliveryAddress: string
│   │   ├── contactNumber: string
│   │   ├── paymentMethod: string
│   │   ├── riderName: string (optional)
│   │   ├── riderEta: string (optional)
│   │   └── deliveryCoordinates: geopoint
│
└── users/
    ├── {userId}
    │   ├── userId: string
    │   ├── email: string
    │   ├── fullName: string
    │   ├── userType: string (customer or vendor)
    │   ├── phoneNumber: string
    │   ├── profileImageUrl: string
    │   ├── primaryAddress: string
    │   ├── createdAt: timestamp
    │   ├── updatedAt: timestamp
    │   │
    │   └── orders/ (subcollection)
    │       ├── {orderId}
    │       │   └── (same as top-level orders structure)
```

---

## ✅ What's Correct

1. **Meals Collection** - Properly structured with vendor info
2. **Orders Collection** - Has all required fields
3. **User Subcollections** - Orders organized by customer
4. **Indexing Strategy** - Using vendorId for queries
5. **Data Types** - Correct field types (integer, string, timestamp)

---

## ⚠️ Issues Found & Fixes Required

### Issue 1: Firebase Configuration Mismatch
**Problem:** iOS config points to different project (`bahaykusina` vs `bahay-kusina-main`)

**Location:** `lib/firebase_options.dart` lines 45-54

**Fix:**
```dart
// Should be:
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'AIzaSyCkM9Ic4m1kyZMnUti0P91POPIaO6-Ob-M',
  appId: '1:337492275214:ios:abcdef1234567890ios',
  messagingSenderId: '337492275214',
  projectId: 'bahay-kusina-main',  // ← MUST match Android/Web
  databaseURL: 'https://bahay-kusina-main.firebaseio.com',
  storageBucket: 'bahay-kusina-main.firebasestorage.app',
  iosBundleId: 'com.example.bahaykusina',
);
```

### Issue 2: Missing Firestore Indexes
**Problem:** Queries might be slow without proper indexes

**Recommended Indexes:**

```
Collection: meals
- Index 1: vendorId (Ascending)
- Index 2: vendorId + type (Ascending, Ascending)

Collection: orders
- Index 1: vendorId (Ascending)
- Index 2: vendorId + status (Ascending, Ascending)
- Index 3: customerId (Ascending)
- Index 4: orderDate (Descending)

Collection: users
- Index 1: userType (Ascending)
```

### Issue 3: Missing Security Rules
**Problem:** Database is vulnerable to unauthorized access

**Recommended Rules:**

```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Orders subcollection - user can read their orders
      match /orders/{orderId} {
        allow read: if request.auth.uid == userId;
        allow write: if request.auth.uid == userId && request.resource.data.customerId == userId;
      }
    }
    
    // Meals - public read, vendor write
    match /meals/{mealId} {
      allow read: if true;
      allow create: if request.auth.uid != null && 
                       request.resource.data.vendorId == request.auth.uid;
      allow update, delete: if request.auth.uid == resource.data.vendorId;
    }
    
    // Orders - customers can create, vendors can read their orders
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.vendorId || 
                     request.auth.uid == resource.data.customerId;
      allow create: if request.auth.uid != null;
      allow update: if request.auth.uid == resource.data.vendorId;
      allow delete: if request.auth.uid == resource.data.vendorId;
    }
    
    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Issue 4: Missing Firebase Storage Rules
**Problem:** Images can be accessed/deleted by anyone

**Recommended Rules:**

```
service firebase.storage {
  match /b/{bucket}/o {
    
    // Images - vendors can upload their own
    match /meals/{vendorId}/{mealId}/{file} {
      allow read: if true;
      allow create: if request.auth.uid == vendorId;
      allow delete: if request.auth.uid == vendorId;
    }
    
    // User profiles
    match /profiles/{userId}/{file} {
      allow read: if true;
      allow create, delete: if request.auth.uid == userId;
    }
    
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Issue 5: Missing Cascade Delete
**Problem:** Deleting user doesn't delete their orders

**Solution:** Use Cloud Functions (implement on Firebase Console)

```javascript
// Cloud Function: deleteUserData
exports.deleteUserData = functions.auth.user().onDelete((user) => {
  const db = admin.firestore();
  
  // Delete user doc
  return db.collection('users').doc(user.uid).delete()
    .then(() => {
      // Delete user's orders
      return db.collection('users')
        .doc(user.uid)
        .collection('orders')
        .get()
        .then(snapshot => {
          const batch = db.batch();
          snapshot.docs.forEach(doc => batch.delete(doc.ref));
          return batch.commit();
        });
    });
});
```

### Issue 6: Data Consistency Issues
**Problem:** Orders in top-level and subcollection could get out of sync

**Solution:** Write to both places atomically using batch writes

**Current Code Location:** `lib/services/firestore_service.dart` lines 147-189

**Status:** ✅ Already implemented correctly with batch writes

---

## 🔧 Implementation Checklist

### Step 1: Fix Firebase Configuration
- [ ] Update iOS config to use `bahay-kusina-main` project
- [ ] Verify all three platforms (Android, iOS, Web) use same project
- [ ] Test on web first (easiest to debug)

### Step 2: Set Up Firestore Indexes
1. Go to Firebase Console → bahay-kusina-main
2. Click "Firestore Database"
3. Click "Indexes" tab
4. Create recommended indexes (may auto-create on first slow query)

### Step 3: Update Security Rules
1. Go to Firebase Console → Firestore Database
2. Click "Rules" tab
3. Copy-paste provided rules above
4. Test rules in "Rules Playground"
5. Publish when satisfied

### Step 4: Update Storage Rules
1. Go to Firebase Console → Storage
2. Click "Rules" tab
3. Copy-paste provided rules above
4. Publish when satisfied

### Step 5: Set Up Cloud Functions (Optional but Recommended)
1. Go to Firebase Console → Functions
2. Create `deleteUserData` function
3. Deploy and test

### Step 6: Verify Data Integrity
1. Add new package as vendor
2. Check it appears in Firestore
3. Place order as customer
4. Verify order in both collections
5. Check real-time streams work

---

## 📊 Expected Database Size

```
Estimated for 1 year of operation:
- Users: 10,000 (100KB each) = 1GB
- Meals: 500 (2KB each) = 1MB  
- Orders: 100,000 (3KB each) = 300MB

Total: ~1.3GB (well within Firestore limits)
```

---

## 🔐 Security Best Practices

✅ Use authentication for all operations
✅ Validate data on client before sending
✅ Use security rules to enforce validation
✅ Never expose secrets in client code
✅ Use Cloud Functions for sensitive operations
✅ Monitor Firestore usage for suspicious activity
✅ Regular backups (enable in Firebase Console)
✅ Version your database schema

---

## 🚀 Performance Optimizations

### Current Implementation
- ✅ Caching (5 minute TTL)
- ✅ Sequential loading (show orders first)
- ✅ Real-time streams (no polling)
- ✅ Fallback data (work offline)

### Additional Optimizations Available
- [ ] Pagination for large lists
- [ ] Denormalization (cache vendor names in orders)
- [ ] Compression for images
- [ ] CDN for static assets
- [ ] Connection pooling

---

## 📝 Database Maintenance

### Regular Tasks
- **Daily:** Monitor Firestore usage/costs
- **Weekly:** Backup critical data
- **Monthly:** Review security rules
- **Quarterly:** Archive old orders (>1 year)

### Cleanup Rules
- Delete orders after 2 years (per privacy policy)
- Soft-delete users (don't delete, just mark inactive)
- Archive test data separately

---

## 🎯 Next Steps

1. **Immediate:** Fix iOS Firebase config
2. **Today:** Deploy Firestore security rules
3. **This Week:** Set up recommended indexes
4. **This Month:** Implement Cloud Functions
5. **Ongoing:** Monitor and optimize

---

## ✅ Verification Checklist

After making changes:

- [ ] All platforms use same Firebase project
- [ ] Security rules deployed and tested
- [ ] Firestore indexes created
- [ ] Storage rules updated
- [ ] Cloud Functions deployed
- [ ] Real-time streams working
- [ ] Package adding works end-to-end
- [ ] Order placement works end-to-end
- [ ] Order notifications work
- [ ] No console errors
- [ ] Data appears in correct collections
- [ ] Cascade deletes work properly

---

## 🆘 Troubleshooting

### "Permission denied" errors
→ Check security rules are deployed correctly

### Slow queries
→ Check Firestore indexes are created

### Data not syncing
→ Check real-time listeners are active

### Images not uploading
→ Check Storage rules and bucket exists

### App crashes on login
→ Verify Firebase config matches project ID

---

## 📞 Firebase Console Links

- **Main Project:** https://console.firebase.google.com/project/bahay-kusina-main
- **Firestore:** bahay-kusina-main/firestore
- **Storage:** bahay-kusina-main/storage
- **Functions:** bahay-kusina-main/functions
- **Rules Playground:** bahay-kusina-main/firestore/rules

