import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:kitchen_order_mgmt_app/models/order.dart';

// This service handles all Firestore operations for the app
// Used by both Customer and Kitchen screens

class FirestoreService {
  // Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ------------------------------------------------------------
  // ADD NEW ORDER (Customer places order)
  // ------------------------------------------------------------
  Future<void> addOrder(Order order) async {
    await _db.collection('orders').add({
      'tableNumber': order.tableNumber.toInt(),
      'sessionId': order.sessionId, // Same for all orders in one session
      'orderNo': order.orderNo.toInt(),
      'status': order.status.name, // pending / preparing / ready / paid
      'time': Timestamp.fromDate(order.time),

      // Save items inside order
      'items': order.items.map((cartItem) {
        return {
          'id': cartItem.item.id,
          'name': cartItem.item.name,
          'price': cartItem.item.price.toDouble(),
          'quantity': cartItem.quantity.toInt(),
        };
      }).toList(),
    });
  }

  // ------------------------------------------------------------
  // LISTEN TO ALL ORDERS (real-time)
  // Used in kitchen dashboard
  // ------------------------------------------------------------
  Stream<QuerySnapshot> getOrdersStream() {
    return _db
        .collection('orders')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // ------------------------------------------------------------
  // UPDATE ORDER STATUS
  // Used by kitchen buttons
  // ------------------------------------------------------------
  Future<void> updateOrderStatus(String docId, String status) async {
    await _db.collection('orders').doc(docId).update({'status': status});
  }

  // ------------------------------------------------------------
  // GET ORDERS FOR A SPECIFIC TABLE
  // Used on customer screen to track their orders
  // ------------------------------------------------------------
  Stream<QuerySnapshot> getOrdersForTable(int tableNo) {
    return _db
        .collection('orders')
        .where('tableNumber', isEqualTo: tableNo)
        .orderBy('time', descending: true)
        .snapshots();
  }

  // ------------------------------------------------------------
  // KITCHEN STREAMS (by status)
  // ------------------------------------------------------------

  // Active orders = pending + preparing
  Stream<QuerySnapshot> getActiveOrdersStream() {
    return _db
        .collection('orders')
        .where('status', whereIn: ['pending', 'preparing'])
        .orderBy('time', descending: true)
        .snapshots();
  }

  // Completed orders = ready
  Stream<QuerySnapshot> getCompletedOrdersStream() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'ready')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // Paid orders
  Stream<QuerySnapshot> getPaidOrdersStream() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'paid')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // ------------------------------------------------------------
  // CUSTOMER SESSION METHODS
  // ------------------------------------------------------------

  // Get all active orders of a table (status != paid)
  // Used for Order Progress screen
  Stream<List<QueryDocumentSnapshot>> getActiveSessionOrders(int tableNo) {
    return _db
        .collection('orders')
        .where('tableNumber', isEqualTo: tableNo)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) {
            final data = doc.data();
            return data['status'] != 'paid';
          }).toList();
        });
  }

  // Combine items from all active orders of a session
  // Used for Session Receipt
  Stream<Map<String, Map<String, dynamic>>> getSessionCombinedItems(
    int tableNo,
  ) {
    return getActiveSessionOrders(tableNo).map((docs) {
      Map<String, Map<String, dynamic>> combined = {};

      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final items = (data['items'] as List?) ?? [];

        for (var item in items) {
          final name = item['name'];
          final price = (item['price'] as num).toDouble();
          final qty = (item['quantity'] as num).toInt();

          if (combined.containsKey(name)) {
            combined[name]!['quantity'] += qty;
          } else {
            combined[name] = {'price': price, 'quantity': qty};
          }
        }
      }
      return combined;
    });
  }

  // Calculate total amount for active session
  Stream<double> getSessionTotal(int tableNo) {
    return getSessionCombinedItems(tableNo).map((items) {
      double total = 0;
      for (var item in items.values) {
        total += item['price'] * item['quantity'];
      }
      return total;
    });
  }

  // ------------------------------------------------------------
  // KITCHEN SESSION GROUPING
  // ------------------------------------------------------------

  // Group READY orders by sessionId
  // Used in Completed tab (one card per session)
  Stream<Map<String, List<QueryDocumentSnapshot>>> getReadySessions() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'ready')
        .snapshots()
        .map((snapshot) {
          Map<String, List<QueryDocumentSnapshot>> sessions = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final sessionId = data['sessionId'];

            sessions.putIfAbsent(sessionId, () => []).add(doc);
          }
          return sessions;
        });
  }

  // Mark all READY orders of a session as PAID
  Future<void> markSessionPaid(String sessionId) async {
    final snapshot = await _db
        .collection('orders')
        .where('sessionId', isEqualTo: sessionId)
        .where('status', isEqualTo: 'ready')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'status': 'paid'});
    }
  }

  // Group PAID orders by sessionId
  // Used in Paid tab
  Stream<Map<String, List<QueryDocumentSnapshot>>> getPaidSessions() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'paid')
        .snapshots()
        .map((snapshot) {
          Map<String, List<QueryDocumentSnapshot>> sessions = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final sessionId = data['sessionId'];

            sessions.putIfAbsent(sessionId, () => []).add(doc);
          }
          return sessions;
        });
  }

  // ------------------------------------------------------------
  // TAB COUNT METHODS (for Kitchen badges)
  // ------------------------------------------------------------

  // Count active orders
  Stream<int> getActiveOrdersCount() {
    return _db.collection('orders').snapshots().map((snapshot) {
      int count = 0;

      for (var doc in snapshot.docs) {
        final status = doc['status'];
        if (status == 'pending' || status == 'preparing') {
          count++;
        }
      }
      return count;
    });
  }

  // Count completed sessions (unique sessionId where status = ready)
  Stream<int> getReadySessionsCount() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'ready')
        .snapshots()
        .map((snapshot) {
          final sessionIds = <String>{};

          for (var doc in snapshot.docs) {
            sessionIds.add(doc['sessionId']);
          }
          return sessionIds.length;
        });
  }

  // Count paid sessions
  Stream<int> getPaidSessionsCount() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'paid')
        .snapshots()
        .map((snapshot) {
          final sessionIds = <String>{};

          for (var doc in snapshot.docs) {
            sessionIds.add(doc['sessionId']);
          }
          return sessionIds.length;
        });
  }

  // ----------------SHARED CART-----------------

  // Add Item or increase item
  Future<void> addToCart(int tableNo, Map<String, dynamic> item) async {
    // Reference to item document inside table cart
    final docRef = _db
        .collection('carts')
        .doc(tableNo.toString())
        .collection('items')
        .doc(item['id']);

    // check if item already exists in cart
    final doc = await docRef.get();

    if (doc.exists) {
      // if exists - increase quantity
      final currentQty = (doc['quantity'] as num).toInt();
      await docRef.update({'quantity': currentQty + 1});
    } else {
      // if not exists create new item with quantity = 1
      await docRef.set({
        'id': item['id'],
        'name': item['name'],
        'price': item['price'],
        'quantity': 1,
      });
    }
  }

  // decrease item or  remove when quantity is zero
  Future<void> decreaseCartItem(int tableNo, String itemId) async {
    // Reference to item document inside table cart
    final docRef = _db
        .collection('carts')
        .doc(tableNo.toString())
        .collection('items')
        .doc(itemId);

    final doc = await docRef.get();

    if (!doc.exists) return;

    final qty = (doc['quantity'] as num).toInt();

    if (qty <= 1) {
      // remove item if quantity becomes zero
      await docRef.delete();
    } else {
      // otherwise decrease quantity
      await docRef.update({'quantity': qty - 1});
    }
  }

  // real-time cart listener
  Stream<QuerySnapshot> getCartStream(int tableNo) {
    return _db
        .collection('carts')
        .doc(tableNo.toString())
        .collection('items')
        .snapshots();
  }

  // clear cart after order is placed
  Future<void> clearCart(int tableNo) async {
    final snapshot = await _db
        .collection('carts')
        .doc(tableNo.toString())
        .collection('items')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
