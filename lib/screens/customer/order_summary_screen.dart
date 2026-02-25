import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/models/cart_item.dart';
import 'package:kitchen_order_mgmt_app/models/order.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';

class OrderSummaryScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final int tableNo;

  const OrderSummaryScreen({
    super.key,
    required this.cartItems,
    required this.tableNo,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  double getTotalAmount() {
    double total = 0;

    for (var cartItem in widget.cartItems) {
      total += cartItem.item.price * cartItem.quantity;
    }
    return total;
  }

  bool _isPlacing = false;
  String? _currentStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Table ${widget.tableNo}",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  final itemTotal = item.item.price * item.quantity;
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.item.name,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),

                          Text("x${item.quantity}"),
                          SizedBox(width: 12),
                          Text(
                            "₹ ${itemTotal.toStringAsFixed(0)}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹ ${getTotalAmount().toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getOrdersForTable(widget.tableNo),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final docs = snapshot.data!.docs;

            QueryDocumentSnapshot latestDoc = docs.first;
            Timestamp? latestTs = latestDoc['time'] as Timestamp?;

            for (var doc in docs) {
              final ts = doc['time'] as Timestamp?;
              if (ts != null &&
                  latestTs != null &&
                  ts.toDate().isAfter(latestTs.toDate())) {
                latestDoc = doc;
                latestTs = ts;
              }
            }
            final data = latestDoc.data() as Map<String, dynamic>;
            _currentStatus = data['status'];
          }

          if (_currentStatus == 'preparing') {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Order already in progress",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isPlacing ? null : placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPlacing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Place Order",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  void placeOrder() async {
    if (_isPlacing) return;
    if (widget.cartItems.isEmpty) return;

    setState(() {
      _isPlacing = true;
    });

    try {
      final order = Order(
        id: DateTime.now().toString(),
        tableNumber: widget.tableNo,
        items: widget.cartItems,
        time: DateTime.now(),
      );

      await FirestoreService().addOrder(order);

      print("Order Placed Successfully");
      Navigator.pop(context, true);
    } catch (e) {
      print("Error placing order: $e");
      setState(() {
        _isPlacing = false;
      });
    }
  }
}
