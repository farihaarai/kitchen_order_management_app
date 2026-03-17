import 'package:cloud_firestore/cloud_firestore.dart';

class KitchenService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // LISTEN TO ALL ORDERS (real-time)
  // Used in kitchen dashboard
  Stream<QuerySnapshot> getOrdersStream() {
    return _db
        .collection('orders')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // UPDATE ORDER STATUS
  // Used by kitchen buttons
  Future<void> updateOrderStatus(String docId, String status) async {
    await _db.collection('orders').doc(docId).update({'status': status});
  }

  // KITCHEN STREAMS (by status)
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
        .where('isRedo', isEqualTo: false)
        .orderBy('time', descending: true)
        .snapshots();
  }

  // Paid orders = paid
  Stream<QuerySnapshot> getPaidOrdersStream() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'paid')
        .orderBy('time', descending: true)
        .snapshots();
  }

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

  // TAB COUNT METHODS (for Kitchen badges)
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

  // ------------REDO---------------
  Future<void> createRedoOrder({
    required Map<String, dynamic> originalData,
    required List<Map<String, dynamic>> redoItems,
  }) async {
    await _db.collection('orders').add({
      'tableNumber': originalData['tableNumber'],
      'sessionId': originalData['sessionId'],
      'orderNo': null,
      'status': 'pending',
      'time': Timestamp.now(),
      'isRedo': true,
      'items': redoItems,
    });
  }

  Stream<QuerySnapshot> getRedoOrdersStream() {
    return _db
        .collection('orders')
        .where('isRedo', isEqualTo: true)
        .snapshots();
  }

  Stream<int> getRedoOrdersCount(DateTime? date) {
    return _db
        .collection('orders')
        .where('isRedo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          int count = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data();

            final Timestamp ts = data['time'];
            final orderDate = ts.toDate();

            if (date != null) {
              if (orderDate.year != date.year ||
                  orderDate.month != date.month ||
                  orderDate.day != date.day) {
                continue;
              }
            }

            count++;
          }

          return count;
        });
  }
}
