import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:kitchen_order_mgmt_app/models/order.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addOrder(Order order) async {
    await _db.collection('orders').add({
      'tableNumber': order.tableNumber.toInt(),
      'status': order.status.name,
      'time': Timestamp.fromDate(order.time),
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

  // Listen to orders collection
  // Send updates whenever data changes
  Stream<QuerySnapshot> getOrdersStream() {
    return _db
        .collection('orders')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // update status method
  Future<void> updateOrderStatus(String docId, String status) async {
    await _db.collection('orders').doc(docId).update({'status': status});
  }

  // Listen to status updates
  // send updates whenever status changes
  Stream<QuerySnapshot> getOrdersForTable(int tableNo) {
    return _db
        .collection('orders')
        .where('tableNumber', isEqualTo: tableNo)
        .orderBy('time', descending: true)
        .snapshots();
  }
}
