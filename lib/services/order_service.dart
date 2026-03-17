import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:kitchen_order_mgmt_app/models/order.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ADD NEW ORDER (Customer places order)
  Future<void> addOrder(Order order) async {
    await _db.collection('orders').add({
      'tableNumber': order.tableNumber.toInt(),
      'sessionId': order.sessionId, // Same for all orders in one session
      'orderNo': order.orderNo.toInt(),
      'status': order.status.name, // pending / preparing / ready / paid
      'time': Timestamp.fromDate(order.time),
      'isRedo': false,

      // Save items inside order
      'items': order.items.map((cartItem) {
        return {
          'id': cartItem.item.id,
          'name': cartItem.item.name,
          'price': cartItem.item.price.toDouble(),
          'quantity': cartItem.quantity.toInt(),
          'category': cartItem.item.category.name,
        };
      }).toList(),
    });
  }

  // GET ORDERS FOR A SPECIFIC TABLE
  Stream<QuerySnapshot> getOrdersForTable(int tableNo) {
    return _db
        .collection('orders')
        .where('tableNumber', isEqualTo: tableNo)
        .orderBy('time', descending: true)
        .snapshots();
  }

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

        final isRedo = data['isRedo'] ?? false;
        if (isRedo) continue; // ignore redo orders
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

  Stream<List<QueryDocumentSnapshot>> getSessionOrders(int tableNo) {
    return _db
        .collection('orders')
        .where('tableNumber', isEqualTo: tableNo)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) {
            final data = doc.data();
            final status = data['status'];
            final isRedo = data['isRedo'] ?? false;

            return status != 'paid' && isRedo == false;
          }).toList();
        });
  }
}
