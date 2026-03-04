# 🍽️ Kitchen Order Management App

A **real-time restaurant ordering system** built with **Flutter + Firebase** that allows customers to place orders by scanning a QR code on their table and enables kitchen staff to manage and track orders efficiently.

The system supports **multi-user shared carts**, **table sessions**, **multiple orders per session**, and **real-time order tracking**.

---

# 🚀 Tech Stack

### Frontend
- Flutter (Web + Mobile)
- Material UI

### Backend
- Firebase Firestore (Realtime database)
- Firebase Hosting

### Architecture
- StreamBuilder-based realtime updates
- Firestore service layer
- Modular widget architecture

---

# 📱 App Overview

The application has **two main interfaces**:

## 👨‍🍳 Kitchen Dashboard

Used by kitchen staff to manage orders.

Features:
- View incoming orders in real time
- Start preparing orders
- Mark orders as ready
- Handle payment per **table session**
- View completed and paid sessions

---

## 🍽️ Customer Interface

Customers scan a **QR code placed on the table** and can:

- Browse the restaurant menu
- Add items to a **shared table cart**
- Place orders
- Track order progress
- View receipts and session bill

Multiple customers at the same table can order **simultaneously**.

---

# ⭐ Core Features

## 1️⃣ QR Code Table Ordering

Customers scan a QR code that routes to:

```
/table/{tableNo}
```

Example:

```
/table/5
```

This loads the menu for **Table 5**.

---

# 🛒 Shared Cart (Multi-User)

Each table has a **shared cart stored in Firestore**.

All users scanning the same QR code see the **same cart in real time**.

### Example

User A adds:

```
Burger x2
```

User B instantly sees:

```
Burger x2
```

Then adds:

```
Pizza x1
```

Cart becomes:

```
Burger x2
Pizza x1
```

### Firestore Structure

```
carts/
   {tableNo}
      items/
         {itemId}
            id
            name
            price
            quantity
```

---

# 🧾 Table Session System

Each table operates using **sessions**.

A session:

- Starts when the **first order is placed**
- Allows multiple orders
- Ends when **payment is marked**

### Session Rules

| Rule | Description |
|-----|-------------|
| Max Orders | 4 orders per session |
| New Session | Starts after payment |
| Session Billing | Combines all orders |
| Kitchen Workflow | Works per order |
| Payment | Handled per session |

---

# 📦 Firestore Order Structure

```
orders/
   orderId
      tableNumber
      sessionId
      orderNo
      status
      time
      items[]
```

Example:

```
tableNumber : 5
sessionId   : t5_1719829212
orderNo     : 2
status      : preparing
items       : [...]
```

---

# 🔄 Order Status Flow

```
pending
   ↓
preparing
   ↓
ready
   ↓
paid
```

---

# 📊 Kitchen Dashboard Tabs

## Active Orders

Shows:

```
pending
preparing
```

Actions:
- Start Preparing
- Mark Ready

---

## Completed Sessions

Orders with status **ready** are grouped by session.

Kitchen sees:

```
Table 5
Burger x2
Pizza x1

Total: ₹560
```

Action:

```
MARK PAID
```

---

## Paid Sessions

Displays previously completed sessions with total amount.

---

# 📈 Customer Order Tracking

Customers can see:

### Single Order

Status bar shows:

```
Order Placed
Preparing
Ready
```

---

### Multiple Orders

Customers see:

```
View Orders Progress
```

Which opens a **timeline view**:

```
Order #1 → Ready
Order #2 → Preparing
Order #3 → Pending
```

---

# 🧾 Session Receipt

Customers can view **combined bill** of all orders in the session.

Example:

```
Burger x3
Pizza x2
Cold Coffee x2

Total: ₹980
```

The receipt updates **in real time**.

---

# 🔄 Real-Time Architecture

Customer Cart

```
carts/{tableNo}/items
```

Customer Orders

```
orders.where(tableNumber == tableNo)
```

Kitchen Active Orders

```
status in [pending, preparing]
```

Completed Sessions

```
status == ready
group by sessionId
```

Paid Sessions

```
status == paid
group by sessionId
```

---

# 🧠 Business Logic

- Shared cart for multiple users per table
- Maximum **4 orders per session**
- Kitchen processes **orders individually**
- Payment handled **per session**
- Real-time synchronization via Firestore streams

---

# 🖥️ Screens

### Customer
- Menu screen
- Shared cart
- Order summary
- Order progress
- Receipt screen

### Kitchen
- Active orders
- Completed sessions
- Paid sessions

---

# 📦 Project Structure

```
lib/
 ├── core/
 │   ├── data/
 │   │   ├── menu_data.dart
 │   │   └── category_data.dart
 │
 ├── enums/
 │   ├── food_type.dart
 │   ├── menu_category.dart
 │   └── order_status.dart
 │
 ├── models/
 │   ├── cart_item.dart
 │   ├── menu_item.dart
 │   └── order.dart
 │
 ├── services/
 │   └── firestore_service.dart
 │
 ├── screens/
 │   ├── customer/
 │   │   ├── customer_screen.dart
 │   │   ├── order_summary_screen.dart
 │   │   ├── order_progress_screen.dart
 │   │   └── receipt_screen.dart
 │   │
 │   └── kitchen/
 │       └── kitchen_screen.dart
 │
 └── widgets/
     ├── customer/
     │   ├── menu_item_tile.dart
     │   ├── category_selector.dart
     │   └── veg_filter.dart
     │
     └── kitchen/
         ├── order_card.dart
         ├── session_completed_card.dart
         └── session_paid_card.dart
```

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

- Disable cart when order is preparing
- Kitchen sound notifications
- Order cancellation
- Table analytics dashboard
- Admin panel
- Customer split billing

---

# 👨‍💻 Author

Developed as a **Flutter + Firebase real-time restaurant ordering system** project.
