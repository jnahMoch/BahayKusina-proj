# Real-Time Map Tracking - Implementation & Debugging Guide

## Overview
The BahayKusina app now has a fully implemented real-time order tracking system that allows customers to track their order status and see rider information as it updates.

## Data Flow

```
Order Creation (place_order_modal.dart)
         ↓
Order saved to Firestore (orders/ORD-{timestamp})
         ↓
Customer clicks "Track Order" (orders_page.dart)
         ↓
TrackOrderPage opens with orderId
         ↓
StreamOrder listener started (firestore_service.dart)
         ↓
Listen to Firestore document changes
         ↓
Vendor updates order status (vendor_order_details_page.dart)
         ↓
Firestore document updated (status, riderName, riderEta)
         ↓
Stream receives update and UI refreshes
         ↓
Customer sees live status changes
```

## Implementation Details

### 1. Order Creation (place_order_modal.dart)
- Creates Order with `orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}'`
- Status set to `OrderStatus.pending`
- Saved to Firestore in two locations:
  - `/users/{userId}/orders/{orderId}` (user's subcollection)
  - `/orders/{orderId}` (top-level for vendor access)

### 2. Firestore Service (firestore_service.dart)
#### createOrder() Method:
```dart
// Saves order with all fields including coordinates
await _db.collection('orders').doc(orderData.orderId).set(orderMap);
```

#### streamOrder() Method (NEW):
```dart
Stream<Order?> streamOrder(String orderId)
```
- Listens to real-time changes on `/orders/{orderId}`
- Parses all fields from Firestore document
- Converts Firestore Timestamp to DateTime
- Handles nullable fields (riderName, riderEta)
- Returns Stream<Order?> that emits whenever document changes
- Includes comprehensive debug logging

### 3. Track Order Page (track_order_page.dart)
#### _listenToOrderUpdates() Method:
```dart
void _listenToOrderUpdates()
```
- Called in initState()
- Cleans orderId (removes '#', ensures 'ORD-' prefix)
- Subscribes to streamOrder() stream
- Calls setState() on each update to refresh UI
- Error handling with stack trace logging

#### _buildMapPlaceholderCard() Method:
- Displays current order status with dynamic text:
  - `OrderStatus.pending` → (no special text)
  - `OrderStatus.confirmed` → "Order Confirmed"
  - `OrderStatus.preparing` → "Preparing Your Order"
  - `OrderStatus.outForDelivery` → "Rider On The Way"
  - `OrderStatus.delivered` → "Order Delivered"
- Shows rider name and ETA from Firestore data
- Updates in real-time as order status changes

### 4. Vendor Order Management (vendor_order_details_page.dart)
#### _updateOrderStatus() Method:
```dart
Future<void> _updateOrderStatus(OrderStatus newStatus)
```
- Updates `/orders/{orderId}` document with new status
- Auto-assigns rider info when status = outForDelivery:
  - riderName: "Mark Santos"
  - riderEta: "15 mins"
- Sets `updatedAt: ServerTimestamp()`
- Firestore triggers stream update to listening customers

## Debug Output

The system includes comprehensive logging with checkmark (✓) for success and X (✗) for errors:

**Track Order Page:**
```
✓ Track Order - Listening to order: "ORD-1234567890"
✓ Track Order - Widget orderId was: "ORD-1234567890"
✓ Track Order - Stream received order: ORD-1234567890
✓ Track Order - Order status: confirmed
✓ Track Order - Rider name: Mark Santos
✓ Track Order - setState called with new order
```

**Firestore Service:**
```
✓ FirestoreService.streamOrder - Starting stream for orderId: "ORD-1234567890"
✓ FirestoreService.streamOrder - Snapshot received, exists: true
✓ FirestoreService.streamOrder - Order data keys: [...]
✓ FirestoreService.streamOrder - Order parsed successfully: ORD-1234567890, status: confirmed
```

## Testing Real-Time Tracking

### Step 1: Place an Order (Customer)
1. Open app as customer
2. Select a meal/package
3. Click "Order Now"
4. Fill in details and confirm
5. Observe order created in Firebase Console
6. Note the orderId (e.g., "ORD-1234567890")

### Step 2: Track Order (Customer)
1. Go to Orders page
2. Click "Track Order" button
3. Observe console logs showing stream started
4. Check that orderId is correctly formatted

### Step 3: Update Status (Vendor)
1. Open app as vendor
2. Go to Orders section
3. Find the order from Step 1
4. Click order to open details
5. Change status from "Pending" → "Confirmed"
6. Observe Firestore update in console
7. Check vendor_order_details.dart shows status changed

### Step 4: Verify Real-Time Update (Customer)
1. Switch back to customer app with Track Order page open
2. Observe console logs:
   - "Stream received order update"
   - "Order status: confirmed"
   - "setState called with new order"
3. UI should refresh automatically showing:
   - Status badge changes to "Order Confirmed"
   - Status list updates with checkmark on confirmed step
4. No page refresh needed - automatic update

### Step 5: Continue Testing (Vendor)
1. Change status: Preparing
   - Customer should see "Preparing Your Order"
2. Change status: Out for Delivery
   - Customer should see "Rider On The Way"
   - Rider name and ETA should appear
3. Change status: Delivered
   - Customer should see "Order Delivered"
   - Status list should show all steps completed

## Troubleshooting

### Issue: "Order not found in Firestore"
**Log:** `✗ FirestoreService.streamOrder - Order "{orderId}" not found in Firestore`

**Solution:**
- Verify orderId format matches exactly in Firestore
- Check that order was saved to `/orders` collection (not just user subcollection)
- Confirm orderId includes "ORD-" prefix

### Issue: Stream receives order but no UI update
**Log:** `✓ Track Order - Stream received order` but UI doesn't change

**Solution:**
- Check if `mounted` check is passing
- Verify setState() is being called
- Check for exceptions in Firestore data parsing
- Ensure Order model constructor receives all required fields

### Issue: Firestore write succeeds but stream doesn't update
**Log:** Vendor status updated successfully, but customer page doesn't refresh

**Solution:**
- Verify vendor is updating `/orders/{orderId}` collection (not user subcollection)
- Check Firestore security rules allow read access
- Confirm stream is properly subscribed (check initState was called)
- Check for network connectivity issues

### Issue: Old order data persists
**Solution:**
- Stream should emit new snapshot whenever document changes
- UI updates via setState automatically
- If seeing cached data, ensure OrderStatus enum values match Firestore strings:
  - "pending" → OrderStatus.pending
  - "confirmed" → OrderStatus.confirmed
  - "preparing" → OrderStatus.preparing
  - "outForDelivery" → OrderStatus.outForDelivery
  - "delivered" → OrderStatus.delivered
  - "cancelled" → OrderStatus.cancelled

## Key Files Modified

1. **firestore_service.dart** - Added streamOrder() method with comprehensive logging
2. **track_order_page.dart** - Enhanced _listenToOrderUpdates() with debugging
3. **vendor_order_details_page.dart** - Updates top-level orders collection
4. **orders_page.dart** - Passes complete orderId without manipulation
5. **order.dart** - Extended OrderStatus enum with confirmed and preparing states

## Next Steps

1. **Test the complete workflow** following the testing section above
2. **Monitor console logs** to verify stream is receiving updates
3. **Check Firestore console** to confirm writes are happening
4. **Enable/disable network** to test offline behavior
5. **Test with multiple devices** for concurrent order tracking

## Performance Considerations

- Stream listener created in initState, disposed in dispose()
- No memory leaks - subscription properly cancelled
- Firestore listeners are efficient (only document-level)
- UI updates only on actual data changes (Firestore optimization)
- Debug logs can be disabled in production by replacing print() with Analytics

---

**Last Updated:** During Track Order Page Enhancement
**Status:** Ready for Testing
**Next:** APK build and deployment
