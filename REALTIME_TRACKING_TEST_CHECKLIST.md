# Real-Time Tracking Quick Test Checklist

## Pre-Test Setup
- [ ] App compiles without errors
- [ ] Firebase project is active and accessible
- [ ] Have two test accounts ready (customer + vendor)
- [ ] Console (debug) is open and monitoring logs
- [ ] Firestore console is open in browser

## Test 1: Order Creation
- [ ] Customer account: Select meal/package
- [ ] Click "Order Now" button
- [ ] Fill form (name, address, phone, payment)
- [ ] Confirm order
- [ ] **Verify:** Console shows `orderId: ORD-{timestamp}`
- [ ] **Verify:** Order appears in Firestore `/orders` collection

## Test 2: Navigate to Track Order
- [ ] Go to Orders page
- [ ] See the newly created order in list
- [ ] Click "Track Order" button
- [ ] **Verify Console Logs:**
  ```
  ✓ Track Order - Listening to order: "ORD-..."
  ✓ FirestoreService.streamOrder - Starting stream for orderId: "ORD-..."
  ✓ FirestoreService.streamOrder - Snapshot received, exists: true
  ✓ FirestoreService.streamOrder - Order parsed successfully
  ```
- [ ] **Verify UI:** Shows order header with Order ID
- [ ] **Verify UI:** Shows "Pending" or initial status

## Test 3: Vendor Updates Order (Confirmed)
- [ ] Switch to vendor account
- [ ] Open vendor home/orders section
- [ ] Find the test order
- [ ] Open order details
- [ ] Click status dropdown, select "Confirmed"
- [ ] **Verify:** Shows success message "Order status updated successfully"
- [ ] **Verify Firestore:** Order document status field = "confirmed"
- [ ] **Verify Console:** Shows `order.update({ status: 'confirmed' })`

## Test 4: Real-Time Update on Customer Side
- [ ] Keep track_order page open on customer account
- [ ] After vendor changes status to Confirmed
- [ ] **Verify Console Logs:**
  ```
  ✓ Track Order - Stream received order update: ORD-...
  ✓ Track Order - Order status: confirmed
  ✓ Track Order - Rider name: undefined (empty initially)
  ✓ Track Order - setState called with new order
  ```
- [ ] **Verify UI Auto-Updates:**
  - Status badge changes to "Order Confirmed"
  - Status timeline shows checkmark on "Confirmed" step
  - No manual page refresh needed

## Test 5: Vendor Updates to Preparing
- [ ] In vendor order details, change status to "Preparing"
- [ ] **Verify Console (Vendor):** Status update succeeds
- [ ] **Verify Console (Customer):** Stream receives new update
- [ ] **Verify UI (Customer):** 
  - Shows "Preparing Your Order" text
  - Status timeline updates automatically
  - Shows checkmarks on Confirmed + Preparing steps

## Test 6: Vendor Updates to Out for Delivery
- [ ] In vendor order details, change status to "Out for Delivery"
- [ ] **Verify Console (Vendor):** Shows rider auto-assigned
- [ ] **Verify Firestore:** 
  - status = "outForDelivery"
  - riderName = "Mark Santos"
  - riderEta = "15 mins"
- [ ] **Verify Console (Customer):** Stream receives update with rider info
- [ ] **Verify UI (Customer):**
  - Shows "Rider On The Way" text
  - Shows rider name "Mark Santos"
  - Shows ETA "15 mins"
  - Status timeline shows in-progress delivery step

## Test 7: Vendor Completes Order
- [ ] In vendor order details, change status to "Delivered"
- [ ] **Verify Console (Vendor):** Status update succeeds
- [ ] **Verify Console (Customer):** Stream receives final update
- [ ] **Verify UI (Customer):**
  - Shows "Order Delivered" text
  - All status timeline steps show checkmarks
  - Shows final status in green

## Test 8: Stream Error Handling
- [ ] Close the app (kills stream subscription)
- [ ] Verify dispose() properly cancels subscription
- [ ] Reopen app and navigate to Track Order again
- [ ] **Verify:** New stream subscription created
- [ ] **Verify:** Shows current order status correctly

## Test 9: Multiple Orders
- [ ] Create 2-3 test orders from different customer accounts
- [ ] Track multiple orders simultaneously
- [ ] Have vendor update different orders
- [ ] **Verify:** Each track_order_page updates independently
- [ ] **Verify:** No cross-contamination between orders

## Test 10: Network Connectivity
- [ ] Turn off WiFi/mobile data
- [ ] Currently tracking order with stream active
- [ ] **Verify:** No crashes, graceful offline handling
- [ ] Turn connectivity back on
- [ ] **Verify:** Stream resumes and receives queued updates

## Success Criteria
- ✅ All console logs show checkmarks (✓) not X (✗)
- ✅ UI updates automatically without page refresh
- ✅ Multiple orders can be tracked simultaneously
- ✅ Order status transitions work: pending → confirmed → preparing → outForDelivery → delivered
- ✅ Rider info appears when status = outForDelivery
- ✅ No console errors or exceptions
- ✅ No memory leaks (streams properly disposed)

## Troubleshooting During Tests

| Issue | Check |
|-------|-------|
| Order not found | Verify orderId format: "ORD-{timestamp}", check Firestore `/orders` collection |
| UI not updating | Check console for "setState called" log, verify mounted check passes |
| Rider info missing | Check firestore shows riderName/riderEta, verify vendor changed to outForDelivery |
| Stream error | Check Firestore security rules, verify network connectivity |
| Old data persists | Clear app cache, restart app, verify stream listener recreated |

## Debug Mode
If any test fails, enable additional debugging:
1. Check Firestore console - verify documents update in real-time
2. Check Flutter console - look for ✓ and ✗ logs
3. Check network tab - verify Firestore requests succeed
4. Check App logs - look for mounted/setState logs
5. Add breakpoints in _listenToOrderUpdates() and streamOrder()

---

Run this checklist before considering real-time tracking complete.
Expected time: 15-20 minutes for full test cycle.
