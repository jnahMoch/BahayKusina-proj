# Firebase Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     BAHAY KUSINA APP                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   ANDROID    │  │     WEB      │  │     iOS      │          │
│  │   (Chrome)   │  │  (Chrome)    │  │  (Device)    │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                 │                 │                  │
│         └─────────────────┼─────────────────┘                  │
│                           │                                    │
│          ┌────────────────▼────────────────┐                  │
│          │  FIREBASE AUTHENTICATION       │                  │
│          │  (Email/Password, Google Auth)  │                  │
│          └────────────────┬────────────────┘                  │
│                           │                                    │
│         ┌─────────────────▼─────────────────┐                 │
│         │     FIREBASE CLOUD SERVICES      │                 │
│         └──────────┬──────────┬──────────┬──┘                 │
│                    │          │          │                    │
│         ┌──────────▼─┐  ┌────▼─────┐  ┌─▼──────────┐         │
│         │ FIRESTORE  │  │ STORAGE  │  │ REALTIME   │         │
│         │ DATABASE   │  │ (Images) │  │ DATABASE   │         │
│         └────────────┘  └──────────┘  └────────────┘         │
│                                                                │
└─────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│              FIRESTORE DATABASE: bahay-kusina-main               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ MEALS           │  │ ORDERS       │  │ USERS        │      │
│  │ (All food items)│  │ (All orders) │  │ (Profiles)   │      │
│  ├─────────────────┤  ├──────────────┤  ├──────────────┤      │
│  │ id              │  │ orderId      │  │ userId       │      │
│  │ type            │  │ vendorId ⭐  │  │ email        │      │
│  │ title           │  │ customerId ⭐│  │ fullName     │      │
│  │ vendorId ⭐     │  │ status       │  │ userType     │      │
│  │ price           │  │ totalAmount  │  │ profileImage │      │
│  │ left (stock)    │  │ items[]      │  │              │      │
│  │ imageUrl        │  │ orderDate    │  │ orders/      │      │
│  │ createdAt       │  │              │  │ (subcoll.)   │      │
│  │ updatedAt       │  │              │  │              │      │
│  └─────────────────┘  └──────────────┘  └──────────────┘      │
│       (~1000)              (~100k)            (~10k)           │
│                                                                  │
│  ⭐ = Indexed for fast queries                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

### Adding a New Meal (Vendor Action)

```
Vendor App               Firebase              Customer App
   │                        │                      │
   ├─ Click "Add Package"   │                      │
   │                        │                      │
   ├─ Fill form             │                      │
   │                        │                      │
   ├─ Upload image ────────►│ Storage Upload       │
   │                        │ (60s timeout)        │
   │                        │                      │
   ├─ Save meal ───────────►│ Firestore Write      │
   │  (vendorId, price...)  │ (batch write)        │
   │                        │                      │
   │                        ├─ Stream Update ──────┼──► Real-time
   │                        │  (streamAllMeals)    │    notification
   │                        │                      │
   │                        │                      ├─ New meal
   │                        │                      │  appears!
   │
   └─ "Saved!" message      │
```

### Placing an Order (Customer Action)

```
Customer App             Firebase              Vendor App
   │                        │                      │
   ├─ Select meals          │                      │
   │                        │                      │
   ├─ Enter address         │                      │
   │                        │                      │
   ├─ Click "Place Order" ──┼────────────────►    │
   │  (create order doc)     │ Firestore Write     │
   │                        │                      │
   │  Show spinner...       ├─ Stream Update      │
   │                        │  (streamVendorOrders)
   │                        │                      ├─ DING! 
   │                        │                      │  New order
   │                        │                      │  notification
   │                        │                      │
   │  "Order Placed!"       │                      ├─ Order in
   │  + Order tracking      │                      │  dashboard
   │                        │                      │
   │                        │                      ├─ Click to
   │                        │                      │  confirm/decline
   │                        │                      │
   │                        │◄─────────────────── │ Update status
   │                        │  (update doc)        │
   │                        │                      │
   ├─ Status updates ◄──────┤ Real-time stream
   │  (preparing, etc.)    │  (streamOrder)
   │
   └─ "Order is being prepared!"
```

### Real-Time Architecture

```
                    ┌──────────────────────┐
                    │   FIRESTORE         │
                    │   DATABASE          │
                    └──────────┬───────────┘
                               │
                    ┌──────────┴───────────┐
                    │                     │
                    ▼                     ▼
              ┌──────────────┐     ┌──────────────┐
              │ STREAM 1     │     │ STREAM 2     │
              │ streamAllMeals
              │              │     │ streamVendor │
              │ (Customers)  │     │ Orders       │
              │              │     │ (Vendors)    │
              └───────┬──────┘     └──────┬───────┘
                      │                   │
            ┌─────────▼────────┐ ┌────────▼───────┐
            │ Customer Home    │ │ Vendor        │
            │ Page             │ │ Dashboard     │
            │                  │ │               │
            │ Updates every    │ │ Notified     │
            │ 500ms when       │ │ immediately  │
            │ meals change     │ │ when order   │
            │                  │ │ arrives      │
            └──────────────────┘ └───────────────┘

✨ No polling! Pure event-based updates ✨
```

## Security Architecture (After Deployment)

```
┌─────────────────────────────────────────────────────────┐
│  UNAUTHENTICATED USER (Not logged in)                   │
├─────────────────────────────────────────────────────────┤
│  ✓ Can read meals collection  (public data)             │
│  ✗ Cannot read orders                                   │
│  ✗ Cannot modify anything                               │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  AUTHENTICATED CUSTOMER USER                             │
├─────────────────────────────────────────────────────────┤
│  ✓ Can read meals collection                            │
│  ✓ Can read own orders (where customerId == auth.uid)   │
│  ✓ Can create new orders (for themselves)               │
│  ✗ Cannot read other customer orders                    │
│  ✗ Cannot modify orders                                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  AUTHENTICATED VENDOR USER                               │
├─────────────────────────────────────────────────────────┤
│  ✓ Can read meals collection                            │
│  ✓ Can read own meals (where vendorId == auth.uid)      │
│  ✓ Can create new meals                                 │
│  ✓ Can update own meals                                 │
│  ✓ Can delete own meals                                 │
│  ✓ Can read own orders (where vendorId == auth.uid)     │
│  ✓ Can update own orders (status changes)               │
│  ✗ Cannot read other vendor's meals                     │
│  ✗ Cannot read other vendor's orders                    │
└─────────────────────────────────────────────────────────┘
```

## Performance Architecture

```
┌─────────────────────────────────────────────────────────┐
│  APP STARTUP (User opens app)                            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─ Show cached data (if available) ──► Instant load   │
│  │                                                      │
│  ├─ Fetch fresh data (10s timeout)                     │
│  │  ├─ Firestore: Get latest meals                    │
│  │  ├─ Firestore: Get vendor orders                   │
│  │  └─ If timeout: Use fallback data                  │
│  │                                                      │
│  └─ Start real-time streams (non-blocking)            │
│     ├─ streamAllMeals() - Detects new items           │
│     └─ streamVendorOrders() - Detects new orders      │
│                                                          │
│  Result: App responsive + real-time updates             │
│                                                          │
└─────────────────────────────────────────────────────────┘

        Cache (5 min)        Real-Time Stream
            │                      │
    Meal fetches from        Updates arrive
    cache first              every 500ms
    (instant!)               when data changes
```

## Image Upload Flow

```
┌─────────────┐
│ User picks  │
│ image file  │
└──────┬──────┘
       │
       ▼
┌─────────────┐        ┌──────────────┐
│ Upload to   │───────►│ Firebase     │
│ Storage     │        │ Storage      │
│             │        │ (60s timeout)│
│ meals/      │        │              │
│ {vendorId}/ │        │ Get download │
│ {mealId}/   │        │ URL          │
│ image.jpg   │        └──────┬───────┘
└─────────────┘               │
                              ▼
                        ┌──────────────┐
                        │ Save URL in  │
                        │ meals doc    │
                        │              │
                        │ imageUrl:    │
                        │ "https://... │
                        └──────┬───────┘
                               │
                               ▼
                        ┌──────────────┐
                        │ Customer sees│
                        │ meal with    │
                        │ image        │
                        │              │
                        │ Cached       │
                        │ locally      │
                        └──────────────┘
```

## Query Indexes

```
Collection: meals
┌──────────────────────┐
│ Fields to search:    │
├──────────────────────┤
│ ✓ vendorId           │ Single field
│ ✓ type               │ Single field
│ ✓ createdAt          │ Single field
│ ✓ vendorId + type    │ Compound index
└──────────────────────┘

Collection: orders
┌──────────────────────┐
│ Fields to search:    │
├──────────────────────┤
│ ✓ vendorId           │ Single field
│ ✓ customerId         │ Single field
│ ✓ status             │ Single field
│ ✓ orderDate          │ Single field
│ ✓ vendorId + status  │ Compound index
│ ✓ customerId + date  │ Compound index
└──────────────────────┘

Each index speeds up queries by ~10-100x
Essential for fast vendor dashboard
```

## Storage Bucket Structure

```
Firebase Storage: bahay-kusina-main.firebasestorage.app
│
└── meals/
    │
    ├── {vendorId}/
    │   │
    │   └── {mealId}/
    │       ├── image.jpg
    │       ├── image-thumbnail.jpg
    │       └── metadata.json
    │
    └── (1000s of vendor folders)
        └── (100s of meal folders each)

Total capacity: Unlimited
Max file size: 5GB (way more than needed)
Access: Vendor can upload/delete their own, everyone can read
```

## Firestore Quota Usage (Estimated)

```
Monthly Usage Example:
─────────────────────

Users: 10,000
Meals: 1,000
Orders: 100,000
Storage: 500MB

Reads:        ~5,000,000  → Cost: ~$0.30  (Free: 50,000)
Writes:       ~500,000    → Cost: ~$0.03  (Free: 20,000)
Deletes:      ~50,000     → Cost: ~$0.03  (Free: 20,000)
Storage:      500MB       → Cost: ~$0.09  (Free: 1GB)
Network:      ~100MB      → Cost: ~$0.00  (Usually free)
                           ─────────────
                           Total: ~$0.45/month

✓ Well within free tier!
✓ No monthly bill
✓ Can handle 10x growth
```

## Error Handling Flow

```
Operation attempted
       │
       ▼
    Network call
       │
       ├─ Success ──► Update UI ──► Done
       │
       ├─ Network error
       │    │
       │    ├─ Retry #1 (1s delay)
       │    ├─ Retry #2 (2s delay)
       │    ├─ Retry #3 (4s delay)
       │    │
       │    └─ All failed:
       │         │
       │         ├─ Show error to user
       │         └─ Use fallback/cached data
       │
       └─ Timeout (10s)
            │
            ├─ Stop waiting
            └─ Use cached data
```

---

## Summary

```
Current Architecture Status:
✅ All platforms point to same Firebase project
✅ Real-time streams active (no polling)
✅ Error handling with retries
✅ Caching with 5-minute TTL
✅ Image upload with timeout
✅ Ready for security rules deployment
```

