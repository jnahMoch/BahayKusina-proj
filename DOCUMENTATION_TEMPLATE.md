# BahayKusina - Documentation

## 1. App Title
**BahayKusina**

## 2. Team Members
*[Enter Team Member Names Here]*

## 3. App Description
BahayKusina is a hyper-local food marketplace designed to connect home-based cooks (nanays, titos, and local culinary enthusiasts) with hungry neighbors. Unlike traditional delivery apps, BahayKusina focuses on "Meal Packages"—bulk or family-sized home-cooked meals that offer better value and a more authentic taste of home.

**Key Features:**
- **Customer Side:** Browse available meal packages by category, real-time stock tracking, secure checkout with location pinning, and order history.
- **Vendor Side:** Comprehensive dashboard for sales data, meal package management (Full CRUD), and order processing.
- **Real-time Notifications:** In-app updates for order status and stock alerts.

## 4. Tech Stack Used
- **Frontend Framework:** Flutter (Dart)
- **Backend/Database:** Firebase Firestore (NoSQL)
- **Authentication:** Firebase Auth
- **State Management:** Provider
- **Mapping/Location:** Google Maps Flutter, Geocoding Service

## 5. Database Structure (Firestore)

### `users` collection:
- `userId`: String (Primary Key)
- `email`: String
- `fullName`: String
- `role`: String (vendor/customer)
- `address`: String
- `phone`: String

### `meals` collection:
- `id`: String (Primary Key)
- `title`: String
- `type`: String (Category)
- `price`: Number
- `left`: Number (Stock Count)
- `vendor`: String
- `vendorId`: String (Foreign Key to users)
- `desc`: String
- `imageUrl`: String

### `orders` collection (and user sub-collection):
- `orderId`: String
- `orderDate`: Timestamp
- `customerId`: String
- `customerName`: String
- `vendorId`: String
- `totalAmount`: Number
- `status`: String (pending/delivered/etc.)
- `items`: List of [mealTitle, quantity, price]
- `deliveryAddress`: String
- `contactNumber`: String

## 6. Screenshots of Major Screens

### [Home Screen]
- *Visualizes the category tabs and meal package cards with dynamic stock indicators.*

### [Cart & Checkout]
- *Shows the itemized summary and the Google Maps location selector.*

### [Vendor Dashboard]
- *Displays business metrics like Total Sales, Pending Orders, and Low Stock Alerts.*

### [Manage Packages]
- *The CRUD interface where vendors can Add, Edit, or Delete their offerings.*

---
*Generated for BahayKusina Final Presentation*
