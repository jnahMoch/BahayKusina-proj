# BahayKusina - Firestore Database Schema

Complete documentation of the database structure for Firebase/Firestore integration.

## Overview

The app uses **Cloud Firestore** (NoSQL database) with the following collections:

```
firestore/
├── meals/                    (Public read, vendor write)
│   ├── meal_001/
│   ├── meal_002/
│   └── ...
├── users/                    (Private, user-specific)
│   ├── {userId}/
│   │   ├── (user profile fields)
│   │   └── orders/
│   │       ├── order_1/
│   │       ├── order_2/
│   │       └── ...
```

---

## Collection 1: `meals`

**Access Level:** Public read, vendor write only

**Document Structure:**

```dart
meals/{mealId}
{
  "type": String,           // Category (Breakfast, Lunch, Dinner, Dessert)
  "title": String,          // Meal name
  "vendor": String,         // Vendor/Restaurant name
  "desc": String,           // Description
  "price": Integer,         // Price in PHP
  "left": Integer,          // Stock available
  "imageUrl": String        // Path to meal image (e.g., assets/images/adobo.jpg)
}
```

### Example Documents

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

### Field Descriptions

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `type` | String | Meal category | "Breakfast", "Lunch", "Dinner", "Dessert" |
| `title` | String | Meal name | "Adobo with Rice" |
| `vendor` | String | Restaurant/vendor name | "HomeCooked Kitchen" |
| `desc` | String | Detailed description | "Savory pork adobo..." |
| `price` | Integer | Price in Philippine Pesos | 85 |
| `left` | Integer | Quantity in stock | 15 |
| `imageUrl` | String | Path to image asset | "assets/images/adobo.jpg" |

### Queries Used

```dart
// Get all meals (sorted by category)
db.collection('meals').get()

// Get meal by ID
db.collection('meals').doc(mealId).get()

// Filter by category (future enhancement)
db.collection('meals').where('type', isEqualTo: 'Breakfast').get()
```

---

## Collection 2: `users`

**Access Level:** Private (user can only read/write their own document)

**Document Structure:**

```dart
users/{userId}
{
  "email": String,              // User email
  "displayName": String,        // Full name
  "phone": String,              // Phone number (optional)
  "address": String,            // Delivery address (optional)
  "role": String,               // "customer" or "vendor"
  "createdAt": Timestamp,       // Account creation time
  "updatedAt": Timestamp,       // Last profile update
  
  // Subcollection: orders
  "orders": {
    {orderId}: {
      // Order fields (see below)
    }
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `email` | String | User's email address |
| `displayName` | String | User's full name |
| `phone` | String | Contact phone number |
| `address` | String | Default delivery address |
| `role` | String | "customer" (buyer) or "vendor" (seller) |
| `createdAt` | Timestamp | Server timestamp when account created |
| `updatedAt` | Timestamp | Server timestamp of last update |

### Example Document

**Document ID:** `abc123def456` (Firebase Auth UID)
```json
{
  "email": "john@test.com",
  "displayName": "John Doe",
  "phone": "09175551234",
  "address": "123 Main St, Manila, 1000",
  "role": "customer",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

### Queries Used

```dart
// Get user profile
db.collection('users').doc(userId).get()

// Create user profile
db.collection('users').doc(userId).set({...})

// Update user profile
db.collection('users').doc(userId).update({...})
```

---

## Subcollection: `users/{userId}/orders`

**Access Level:** Private (user can read their own orders only)

**Document Structure:**

```dart
users/{userId}/orders/{orderId}
{
  "orderId": String,              // Unique order ID (e.g., "ORD-12345")
  "orderDate": Timestamp,         // When order was placed
  "items": [
    {
      "mealTitle": String,        // Meal name
      "quantity": Integer,        // How many
      "pricePerUnit": Integer,    // Price per meal
    },
    // ... more items
  ],
  "totalAmount": Integer,         // Total price in PHP
  "status": String,               // pending, outForDelivery, delivered, cancelled
  "deliveryAddress": String,      // Where to deliver
  "contactNumber": String,        // Delivery contact
  "paymentMethod": String,        // How they paid
  "riderName": String?,           // Delivery person (optional)
  "riderEta": String?             // Estimated arrival (optional)
}
```

### Field Descriptions

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `orderId` | String | Unique identifier | "ORD-12345" |
| `orderDate` | Timestamp | When order placed | 2024-01-15T14:30:00Z |
| `items` | Array | Items in order | [{...}, {...}] |
| `items[].mealTitle` | String | Item name | "Adobo with Rice" |
| `items[].quantity` | Integer | Quantity ordered | 2 |
| `items[].pricePerUnit` | Integer | Price per unit | 85 |
| `totalAmount` | Integer | Total order value | 480 |
| `status` | String | Order progress | "pending", "outForDelivery", "delivered", "cancelled" |
| `deliveryAddress` | String | Delivery location | "123 Main St, Manila" |
| `contactNumber` | String | Contact for delivery | "09175551234" |
| `paymentMethod` | String | Payment type | "Cash on Delivery", "GCash", "Card" |
| `riderName` | String | Rider name (optional) | "Juan dela Cruz" |
| `riderEta` | String | Estimated arrival (optional) | "30 mins" |

### Example Document

**Collection Path:** `users/abc123def456/orders`

**Document ID:** Auto-generated by Firestore (e.g., `order_abc123`)
```json
{
  "orderId": "ORD-12345",
  "orderDate": "2024-01-15T14:30:00Z",
  "items": [
    {
      "mealTitle": "Adobo with Rice",
      "quantity": 2,
      "pricePerUnit": 85
    },
    {
      "mealTitle": "Sinigang na Baboy",
      "quantity": 1,
      "pricePerUnit": 95
    }
  ],
  "totalAmount": 265,
  "status": "pending",
  "deliveryAddress": "123 Main St, Manila, 1000",
  "contactNumber": "09175551234",
  "paymentMethod": "Cash on Delivery",
  "riderName": null,
  "riderEta": null
}
```

### Order Status Values

Only these values are allowed:
- `"pending"` - Order placed, awaiting confirmation
- `"outForDelivery"` - Rider is on the way
- `"delivered"` - Order completed
- `"cancelled"` - Order cancelled

### Queries Used

```dart
// Get all user's orders (sorted by date, newest first)
db.collection('users').doc(userId)
  .collection('orders')
  .orderBy('orderDate', descending: true)
  .get()

// Create new order
db.collection('users').doc(userId)
  .collection('orders')
  .add({...})

// Update order status
db.collection('users').doc(userId)
  .collection('orders')
  .where('orderId', isEqualTo: orderId)
  .limit(1)
  .get()
  .then(snapshot => snapshot.docs[0].ref.update({status: 'outForDelivery'}))
```

---

## Firestore Security Rules

These rules are applied to the database:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Users can read/write their own orders
      match /orders/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Anyone can read meals, only vendors can write
    match /meals/{document=**} {
      allow read: if true;
      allow write: if request.auth.uid != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'vendor';
    }
  }
}
```

### Rule Breakdown

1. **Users Collection:**
   - ✅ Can read own profile (`users/{userId}`)
   - ✅ Can write own profile
   - ✅ Can read own orders (`users/{userId}/orders/*`)
   - ✅ Can create own orders
   - ❌ Cannot access other users' data

2. **Meals Collection:**
   - ✅ Everyone can read meals
   - ✅ Only vendors can create/update meals
   - ❌ Regular customers cannot modify meals

---

## Data Size & Growth

### Current Size
- **Meals:** ~4 documents × 1 KB = 4 KB
- **Users:** ~1 document × 500 bytes = 500 bytes
- **Orders:** Grows with each order placed

### Estimated Monthly Growth
- Assuming 100 new users/month
- Assuming 500 orders/month
- Each order: ~500 bytes
- Monthly growth: ~250 KB

### Annual Estimate
- Users: ~1200 × 500 bytes = 600 KB
- Orders: ~6000 × 500 bytes = 3 MB
- **Total: ~4 MB per year**

Firestore free tier: **1 GB included** (sufficient for years)

---

## Dart Models Mapping

The Dart models map to Firestore documents:

### MealPackage Model
```dart
MealPackage {
  type: String,       → meals.type
  title: String,      → meals.title
  vendor: String,     → meals.vendor
  desc: String,       → meals.desc
  price: int,         → meals.price
  left: int,          → meals.left
  imageUrl: String    → meals.imageUrl
}
```

### AuthUser Model
```dart
AuthUser {
  userId: String,      → users.{userId}
  email: String,       → users.email
  fullName: String,    → users.displayName
  phone: String,       → users.phone
  address: String,     → users.address
  role: UserRole,      → users.role
  createdAt: DateTime  → users.createdAt
}
```

### Order Model
```dart
Order {
  orderId: String,           → orders.orderId
  orderDate: DateTime,       → orders.orderDate
  items: List<OrderItem>,    → orders.items[]
  totalAmount: int,          → orders.totalAmount
  status: OrderStatus,       → orders.status
  deliveryAddress: String,   → orders.deliveryAddress
  contactNumber: String,     → orders.contactNumber
  paymentMethod: String,     → orders.paymentMethod
  riderName: String?,        → orders.riderName
  riderEta: String?          → orders.riderEta
}
```

---

## Maintenance & Best Practices

### Regular Backups
1. Export collection periodically
2. Store in Cloud Storage
3. Keep version history

### Indexing
Firestore automatically creates indexes for:
- Single field queries
- Manually create composite indexes for complex queries

### Monitoring
1. Monitor data growth in Firebase Console
2. Check billing monthly
3. Watch for slow queries

### Data Cleanup
- Archive old orders (older than 1 year)
- Delete inactive user accounts
- Remove duplicate user profiles

### Performance Tips
- Use batch writes for multiple documents
- Limit subcollection queries (use pagination)
- Cache frequently accessed data in app
- Denormalize data when necessary

---

## Future Enhancement Ideas

### New Collections
- `restaurants` - Vendor/restaurant profiles
- `reviews` - Meal reviews and ratings
- `favorites` - User favorites/bookmarks
- `promotions` - Current deals and coupons

### New Fields
- Meal ratings and review counts
- Allergies/dietary info
- Prep time estimate
- Delivery fee details
- Loyalty points tracking

### New Features
- Meal search with full-text index
- Filter by price/rating/category
- Real-time order status websockets
- Vendor analytics dashboard
- Customer order history export

---

## Troubleshooting

### Issue: "Permission denied" reading meals
**Solution:** Check Firestore rules - `allow read: if true;` for meals collection

### Issue: Orders not saving
**Solution:** Verify user is authenticated and `users/{uid}` document exists

### Issue: Slow query performance
**Solution:** Create composite index for complex queries (Firestore will suggest)

### Issue: Data not updating in app
**Solution:** Check if app has correct field names matching Firestore exactly

---

## References

- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Firestore Pricing](https://firebase.google.com/pricing)
