# Real-Time Order Tracking Implementation

## Overview
The vendor area now automatically detects and displays customer orders in real-time as they are placed. When a customer checks out an order, it immediately appears in the vendor dashboard with live status tracking and notifications.

## Features Implemented

### 1. Real-Time Order Stream
**File:** `lib/services/firestore_service.dart`
- Added `streamVendorOrders(vendorId)` method
- Continuously listens to Firestore orders collection
- Automatically pushes order updates to vendor dashboard
- Orders sorted by date (newest first)

**Key Code:**
```dart
Stream<List<order_models.Order>> streamVendorOrders(String vendorId) {
  return _db.collection('orders')
    .where('vendorId', isEqualTo: vendorId)
    .orderBy('orderDate', descending: true)
    .snapshots()
    .map((snapshot) => /* Parse orders */);
}
```

### 2. Vendor Provider Real-Time Tracking
**File:** `lib/providers/vendor_provider.dart`
- Added `startRealtimeOrderTracking(vendorId)` method
- Listens to order stream and detects new pending orders
- Automatically notifies when customer places order
- Tracks unread order count

**Key Additions:**
```dart
void startRealtimeOrderTracking(String vendorId) {
  _firestoreService.streamVendorOrders(vendorId).listen((orders) {
    // Detect new orders vs old orders
    // Update notification message
    // Increment unread count
    notifyListeners(); // UI updates automatically
  });
}
```

### 3. New Order Notifications
**File:** `lib/screens/vendor_home_page.dart`
- Automatically shows snackbar when customer places order
- Green notification with customer name, item count, and total amount
- "View" button to navigate to Orders tab

**Notification Example:**
```
🔔 New Order! Juan Dela Cruz ordered 2 item(s) - ₱450
[View] [Dismiss]
```

### 4. Visual Indicators for New Orders
**File:** `lib/screens/orders_view.dart`
- Red "NEW" badge appears on orders less than 5 minutes old
- Badge automatically disappears after 5 minutes
- Helps vendor quickly identify newly arrived orders

## Order Status Flow

```
Customer Checkout
       ↓
Order Created in Firestore
       ↓
Real-Time Stream Detects Order
       ↓
Notification Shown to Vendor
       ↓
"NEW" Badge Appears on Order Card
       ↓
Vendor Accepts/Confirms Order
       ↓
Status Updates to "Confirmed"
       ↓
Real-Time Stream Updates UI
       ↓
Vendor Updates to "Preparing"
       ↓
Customer Sees Live Status Update
       ↓
... (out for delivery, delivered, etc.)
```

## Order Status Tracking

The vendor can update order status to:
- **Pending** - Initial state when customer places order
- **Confirmed** - Vendor accepts the order
- **Preparing** - Order is being prepared in kitchen
- **Out for Delivery** - Rider is delivering the order
- **Delivered** - Order successfully delivered
- **Cancelled** - Order was cancelled

## Real-Time Updates

### For Vendor:
1. **Immediate Detection** - Order appears instantly when customer checks out
2. **Live Notifications** - Snackbar alert with order details
3. **Status Tracking** - Update order status and see changes reflected immediately
4. **Real-Time Metrics** - Dashboard metrics update as orders come in

### For Customer:
1. **Live Status Updates** - See order status change from "Pending" → "Preparing" → "Out for Delivery" → "Delivered"
2. **Real-Time Tracking** - Track order progress in real-time
3. **Instant Notifications** - Get notified when vendor confirms/starts preparing order

## Implementation Details

### Firestore Queries
Orders are fetched with:
```
WHERE vendorId == (current vendor)
ORDER BY orderDate DESC
LISTEN in real-time
```

### Stream Processing
- Orders are continuously streamed from Firestore
- Automatically parsed with status validation
- Handles missing fields gracefully
- Errors caught and logged without breaking the stream

### State Management
- VendorProvider manages order state
- Consumer widgets rebuild automatically on state changes
- Notification cleared after displaying
- Unread count tracked for badge/indicators

## Testing the Feature

### Manual Testing Steps:
1. Vendor logs in to vendor dashboard
2. In another browser/device, customer places an order
3. Vendor dashboard automatically shows:
   - Green snackbar notification with order details
   - "NEW" badge on order card in Orders tab
   - Updated metrics (Total Orders, Pending Orders)
4. Vendor clicks "Confirm" to accept order
5. Status updates to "Confirmed" in real-time
6. Customer sees status update immediately

### Firebase Console Verification:
1. Go to Firestore > orders collection
2. Create new document with:
   ```
   vendorId: "vendor_nanay"
   status: "pending"
   orderDate: current timestamp
   customerName: "Test Customer"
   items: [{mealTitle: "Test Meal", quantity: 1, pricePerUnit: 100}]
   totalAmount: 100
   deliveryAddress: "Test Address"
   contactNumber: "09171234567"
   paymentMethod: "GCash"
   ```
3. Watch vendor dashboard - should get notification immediately

## Performance Considerations

- **Streaming**: Efficient real-time updates without polling
- **Caching**: Initial load uses cache, stream provides live updates
- **Battery**: Minimal battery impact with efficient Firestore listeners
- **Bandwidth**: Only changed orders trigger updates
- **Error Handling**: Graceful fallback to cached data if stream fails

## Files Modified

1. **lib/services/firestore_service.dart**
   - Added `streamVendorOrders()` method
   - 90+ lines of streaming logic with parsing

2. **lib/providers/vendor_provider.dart**
   - Added `startRealtimeOrderTracking()` method
   - Added `newOrderNotification` property
   - Added `unreadOrderCount` property
   - Added `clearNotification()` method

3. **lib/screens/vendor_home_page.dart**
   - Added `_startRealtimeTracking()` in initState
   - Added notification snackbar display in Consumer builder
   - Shows green notification with "View" button

4. **lib/screens/orders_view.dart**
   - Added "NEW" badge for orders < 5 minutes old
   - Visual highlight for newly arrived orders

## Future Enhancements

- Push notifications via Firebase Cloud Messaging
- Sound/vibration alert for new orders
- Vendor can snooze/mute notifications
- Order notification history log
- Batch order notifications if multiple arrive together
- Estimated preparation time tracking
- Auto-status updates (prepare after 30s, delivery after 2min, etc.)
