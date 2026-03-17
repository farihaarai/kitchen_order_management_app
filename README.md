# 🍽️ Kitchen Order Management App

A **full-featured real-time restaurant ordering system** built with **Flutter + Firebase**, enabling seamless interaction between **customers, kitchen staff, and admin**.

Customers place orders via QR code, kitchen staff manage orders in real time, and admins monitor **analytics, sales, and performance insights**.

---

# 🚀 Tech Stack

## Frontend
- Flutter (Web + Mobile)
- Material UI
- Responsive Layouts

## Backend
- Firebase Firestore (Realtime Database)
- Firebase Hosting

## State Management
- BLoC (Business Logic Component)

## Routing
- GoRouter (URL-based navigation)

---

# 🧠 Architecture

- BLoC-based state management for order handling
- Service layer abstraction:
  - CartService
  - OrderService
  - KitchenService
  - AnalyticsService
- StreamBuilder + Firestore for real-time updates
- Modular widget-based UI

---

# 📱 Application Modules

The system consists of **3 main roles**:

---

## 🍽️ 1. Customer Interface

Accessible via QR code:

```
/table/{tableNo}
```

### Features

- Browse categorized menu (Starters, Curries, Biryani, etc.)
- Veg / Non-Veg filtering
- Add items to **shared real-time cart**
- View live cart updates
- Place multiple orders in a session
- Order progress tracking (timeline view)
- Floating real-time order status indicator
- View full session receipt
- Responsive UI (mobile/tablet/web)

---

## 👨‍🍳 2. Kitchen Dashboard

Accessible via:

```
/kitchen
```

### Features

- Kitchen login system
- Real-time incoming orders
- Order status management:
  - Start Preparing
  - Mark Ready
- **Sound alerts for new orders 🔊**
- Handles **redo orders separately**
- Order prioritization:
  - Redo orders shown first
- Session-based order grouping
- Clean card-based UI

---

## 📊 3. Admin Dashboard

Accessible via:

```
/admin
```

### Features

- 📅 Date-based filtering (All-time / specific date)
- 💰 Sales analytics
- 📦 Total & daily orders
- 🍽️ Active tables tracking
- 🔁 Redo orders tracking
- ⏰ Peak order hours
- 📊 Average order value

### Visual Insights

- Sales chart
- Orders chart
- Daily trends
- Category distribution (pie chart)
- Top selling items
- Most redone items

---

# ⭐ Core Features

---

## 🔗 QR Code Table Ordering

- Each table has a unique URL:
  ```
  /table/5
  ```
- Opens customer menu instantly

---

## 🛒 Shared Cart (Multi-User)

- Real-time shared cart per table
- Multiple users can add items simultaneously

```
carts/{tableNo}/items
```

---

## 🧾 Table Session System

Each table operates in **sessions**:

| Rule | Description |
|-----|------------|
| Max Orders | 4 per session |
| Session Start | First order |
| Session End | After payment |
| Billing | Combined |
| Kitchen | Order-wise |

---

## 📦 Firestore Data Structure

### Orders

```
orders/
   orderId
      tableNumber
      sessionId
      orderNo
      status
      isRedo
      time
      items[]
```

---

## 🔄 Order Status Flow

```
pending → preparing → ready → paid
```

---

## 🔁 Redo Order System

- Orders can be marked as **redo**
- Redo orders:
  - Highlighted in UI
  - Shown separately in timeline
  - Prioritized in kitchen
  - Tracked in analytics

---

## 🔊 Kitchen Sound Alerts

- Plays sound when:
  - New order arrives
- Improves kitchen responsiveness

---

## 📈 Real-Time Order Tracking

### Single Order

```
Order Placed → Preparing → Ready
```

### Multiple Orders

- Timeline-based UI
- Sorted by order number
- Redo orders grouped separately

---

## 🧾 Session Receipt

- Combines all orders
- Real-time updates
- Clean bill format
- Shows:
  - Order-wise breakdown
  - Total amount

---

## 📊 Analytics Engine

Powered by `AnalyticsService`

### Metrics

- Total Sales
- Orders Count
- Active Tables
- Redo Orders
- Peak Hours
- Average Order Value

### Insights

- Top selling items
- Most redone items
- Category distribution
- Daily trends

---

# 🔄 Real-Time Architecture

| Feature | Firestore Query |
|--------|----------------|
| Cart | `carts/{tableNo}/items` |
| Orders | `orders.where(tableNumber)` |
| Active Orders | `status in [pending, preparing]` |
| Completed | `status == ready` |
| Paid | `status == paid` |

---

# 🖥️ Screens

## Customer
- Welcome screen
- Menu screen
- Cart view
- Order summary
- Order progress (timeline)
- Session receipt

## Kitchen
- Login screen
- Active orders
- Completed sessions
- Paid sessions

## Admin
- Analytics dashboard
- Charts & insights
- Date filtering

---

# 📦 Project Structure

```
lib/
 ├── app.dart
 ├── app_router.dart
 │
 ├── blocs/
 │   └── order/
 │       ├── order_bloc.dart
 │       ├── order_event.dart
 │       └── order_state.dart
 │
 ├── core/
 │   └── data/
 │       ├── menu_data.dart
 │       └── category_data.dart
 │
 ├── enums/
 ├── models/
 │
 ├── services/
 │   ├── cart_service.dart
 │   ├── order_service.dart
 │   ├── kitchen_service.dart
 │   └── analytics_service.dart
 │
 ├── screens/
 │   ├── customer/
 │   ├── kitchen/
 │   └── admin/
 │
 └── widgets/
     ├── customer/
     ├── kitchen/
     └── admin/
```

---

# 🌐 Routing

| Route | Description |
|------|------------|
| `/table/:tableNo` | Customer |
| `/kitchen` | Kitchen login |
| `/admin` | Admin dashboard |

---

# 🌐 Deployment

Hosted using:

```
Firebase Hosting
```

Supports:
- Flutter Web
- Mobile

---

# 📌 Future Enhancements

- Role-based authentication (Admin/Kitchen)
- Payment gateway integration
- Push notifications
- Table reservation system
- Inventory management
- AI-based demand prediction

---

# 👨‍💻 Author

Developed as a **production-level Flutter + Firebase real-time restaurant system** with:

- Customer ordering
- Kitchen workflow management
- Admin analytics dashboard
