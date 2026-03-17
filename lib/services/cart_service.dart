import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
