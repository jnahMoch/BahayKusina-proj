# BahayKusina - Mobile Application Documentation

---

## App Title
# **BahayKusina**
### *Home-Cooked Meals Delivery Platform*

---

## Team Members

| Name | Role |
|------|------|
| [Team Member 1] | Developer |
| [Team Member 2] | Developer |
| [Team Member 3] | Developer |
| [Team Member 4] | Developer |

*(Please fill in your team member names)*

---

## App Description

**BahayKusina** is a mobile food delivery application that connects home-based food vendors (home cooks) with customers looking for authentic, home-cooked Filipino meals.

### Key Features:

#### For Customers:
- **Browse Meals** - View available meal packages from various home cooks
- **Category Filtering** - Filter meals by category (Breakfast, Lunch, Dinner, Merienda, Dessert)
- **Shopping Cart** - Add multiple items to cart before checkout
- **Order Tracking** - Real-time order status updates
- **Multiple Payment Options** - Cash on Delivery, GCash, Maya
- **Address Management** - Save multiple delivery addresses with map integration
- **Notifications** - Receive updates on order status

#### For Vendors:
- **Package Management** - Add, edit, and delete meal packages
- **Order Management** - View and process incoming orders
- **Status Updates** - Update order status (Pending → Confirmed → Preparing → Out for Delivery → Delivered)
- **Dashboard** - View sales metrics and active packages
- **Real-time Orders** - Receive new orders instantly

### Technology Stack:
- **Framework:** Flutter (Dart)
- **Backend:** Firebase (Authentication, Firestore, Cloud Storage)
- **Maps:** Google Maps API
- **State Management:** Provider
- **Platform:** Android, iOS, Web

---

## Screenshots of Major Screens

### 1. Welcome Screen
The landing page where users choose to login or create an account.

![Welcome Screen](screenshots/welcome_screen.png)

---

### 2. Login Page
Users can login as either Customer or Vendor with email and password.

![Login Page](screenshots/login_page.png)

---

### 3. Sign Up Page
New users can create an account by providing:
- Full Name
- Email
- Phone Number
- Password
- Delivery Address (with map picker)
- Role Selection (Customer/Vendor)

![Sign Up Page](screenshots/signup_page.png)

---

### 4. Customer Home Page
Displays available meal packages with:
- Category tabs (All, Breakfast, Lunch, Dinner, Merienda, Dessert)
- Search functionality
- Meal cards with image, title, vendor, description, price, and stock
- Order button for each meal

![Customer Home Page](screenshots/customer_home.png)

---

### 5. Order Details Page
Shows meal details and allows customers to:
- Select quantity
- View total price
- Add to cart

![Order Details](screenshots/order_details.png)

---

### 6. Shopping Cart
Displays items added to cart with:
- Quantity adjustment
- Remove item option
- Subtotal calculation
- Proceed to checkout button

![Shopping Cart](screenshots/cart.png)

---

### 7. Checkout Page
Customers can:
- Enter/select delivery address
- Choose payment method (COD, GCash, Maya)
- View order summary
- Place order

![Checkout Page](screenshots/checkout.png)

---

### 8. Order Confirmation
Displays order confirmation with:
- Order ID
- Total amount
- Delivery address
- Estimated delivery time
- Real-time tracking map

![Order Confirmation](screenshots/order_confirmation.png)

---

### 9. Customer Orders Page
Shows all customer orders with:
- Order status
- Order details
- Tracking information

![Customer Orders](screenshots/customer_orders.png)

---

### 10. Vendor Home Page (Dashboard)
Vendor dashboard showing:
- Total orders count
- Total sales
- Active packages
- Pending orders
- Navigation to Manage Packages and Orders

![Vendor Dashboard](screenshots/vendor_dashboard.png)

---

### 11. Manage Packages (Vendor)
Vendors can view and manage their meal packages:
- Add new package
- Edit existing package
- Delete package
- View package details

![Manage Packages](screenshots/manage_packages.png)

---

### 12. Add/Edit Package (Vendor)
Form to add or edit a meal package:
- Package title
- Category selection
- Price
- Stock quantity
- Description
- Image URL

![Add Package](screenshots/add_package.png)

---

### 13. Vendor Orders Page
Displays incoming orders with:
- Customer name
- Order items
- Total amount
- Status update options
- Order details

![Vendor Orders](screenshots/vendor_orders.png)

---

### 14. Profile/Settings
User profile management:
- Edit profile information
- Manage addresses
- View notifications
- App settings
- Logout

![Profile Settings](screenshots/profile.png)

---

## App Flow Diagram

```
┌─────────────────┐
│  Welcome Screen │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌───▼───┐
│ Login │ │Sign Up│
└───┬───┘ └───┬───┘
    │         │
    └────┬────┘
         │
    ┌────┴────┐
    │         │
┌───▼────┐ ┌──▼───────┐
│Customer│ │  Vendor  │
│  Home  │ │ Dashboard│
└───┬────┘ └────┬─────┘
    │           │
┌───▼────┐ ┌────▼──────┐
│Browse  │ │  Manage   │
│ Meals  │ │ Packages  │
└───┬────┘ └────┬──────┘
    │           │
┌───▼────┐ ┌────▼──────┐
│  Cart  │ │  Orders   │
└───┬────┘ └───────────┘
    │
┌───▼────┐
│Checkout│
└───┬────┘
    │
┌───▼────────┐
│Order       │
│Confirmation│
└────────────┘
```

---

## Database Schema (Firebase Firestore)

### Collections:

1. **users** - User profiles
   - userId, email, displayName, phone, role, addresses

2. **meals** - Meal packages
   - title, type, price, left, desc, vendorId, vendor, imageUrl

3. **orders** - All orders
   - orderId, orderDate, items, totalAmount, status, vendorId, customerId, deliveryAddress

---

## Contact Information

**Project Repository:** [GitHub Repository URL]

**Developed for:** [Course/Subject Name]

**Academic Year:** 2025-2026

---

*Document Generated: January 9, 2026*
