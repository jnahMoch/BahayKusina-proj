# BahayKusina - Presentation Script

## 1. App Pitch (1 Minute)
"Good day everyone! Meet **BahayKusina**. We all love home-cooked meals, but they are often hard to find unless you're dining in a relative's kitchen. On the other side, many talented home cooks want to share their food but find the barriers to commercial apps too high. 

BahayKusina bridges this gap. We are a hyper-local marketplace that empowers home-based vendors to sell 'Meal Packages' directly to their neighborhood. We aren't just selling food; we're selling a taste of home, supporting local micro-entrepreneurs, and providing families with affordable, hearty meals."

## 2. Live Demo (5 Minutes)

### Phase 1: The Discovery (User Side) - 1.5 mins
- **Action:** Open the app to the Welcome Screen and Login. Show the Home Page.
- **Narrative:** "Our interface is designed for simplicity. Users can quickly filter by category—Breakfast, Lunch, or our favorite, Merienda. Notice the dynamic stock badges; it creates a sense of freshness and urgency."
- **Action:** Select a meal (e.g., 'Silog Special'), show the details.

### Phase 2: Transactional Flow (Ordering) - 1.5 mins
- **Action:** Add to cart, go to Cart Page.
- **Narrative:** "Adding items is seamless. In the checkout, we've integrated Google Maps so users can pin their exact delivery location, ensuring our local riders never get lost."
- **Action:** Place the order. Show the confirmation.

### Phase 3: The Business Engine (Vendor Side) - 2 mins
- **Action:** Switch to Vendor Account.
- **Narrative:** "Now, let’s look at the vendor's side. This is the heart of the app. A clean dashboard provides instant metrics: Sales, Pending Orders, and crucial Low Stock Alerts."
- **Action:** Go to 'Manage Packages'. Edit a package price or stock.
- **Narrative:** "Vendors have full CRUD control. If a vendor runs out of ingredients, they can instantly update their stock or hide the package, keeping the data synchronized for all customers."
- **Action:** Show an incoming order in the 'Orders' view.

## 3. Technical Discussion (2-3 Minutes)
- **Key Points:**
  - "We built this using **Flutter** for a high-performance, single-codebase experience."
  - "Our backend is powered by **Firebase Firestore**, which allows us to have real-time synchronization between the vendor's stock and the customer's view."
  - "We utilized **State Management with Provider** to ensure that the cart and authentication states are consistent across all screens without sacrificing performance."

## 4. Closing
"Thank you for your time. We are BahayKusina—bringing the kitchen next door to your table. We’re now ready for your questions."
