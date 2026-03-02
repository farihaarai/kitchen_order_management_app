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
  // Calculate total price of current cart
  double getTotalAmount() {
    double total = 0;
    for (var cartItem in widget.cartItems) {
      total += cartItem.item.price * cartItem.quantity;
    }
    return total;
  }

  bool _isPlacing = false; // Prevent multiple clicks
  String? _currentStatus; // Latest order status for this table

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

      // ---------------- Order Items ----------------
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // List of selected items
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text("x${item.quantity}"),
                          const SizedBox(width: 12),
                          Text(
                            "₹ ${itemTotal.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Total section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹ ${getTotalAmount().toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),

      // ---------------- Bottom Button ----------------
      // Checks latest order status for this table.
      // If kitchen is preparing, block new order.
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getOrdersForTable(widget.tableNo),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final docs = snapshot.data!.docs;

            // Find latest order by time
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

          // If latest order is still preparing, do not allow new order
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

          // Otherwise show Place Order button
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isPlacing ? null : placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPlacing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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

  // Handles session logic and saves order to Firestore
  void placeOrder() async {
    if (_isPlacing) return;
    if (widget.cartItems.isEmpty) return;

    setState(() {
      _isPlacing = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // Get all orders for this table
      final snapshot = await firestore
          .collection('orders')
          .where('tableNumber', isEqualTo: widget.tableNo)
          .get();

      // Active orders = status not paid (same session)
      final activeOrders = snapshot.docs.where((doc) {
        final status = doc['status'];
        return status != 'paid';
      }).toList();

      String sessionId;
      int orderNo;

      if (activeOrders.isEmpty) {
        // Start new session
        sessionId =
            "t${widget.tableNo}_${DateTime.now().millisecondsSinceEpoch}";
        orderNo = 1;
      } else {
        // Continue existing session
        sessionId = activeOrders.first['sessionId'];
        orderNo = activeOrders.length + 1;

        // Allow maximum 4 orders per session
        if (orderNo > 4) {
          setState(() {
            _isPlacing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Maximum 4 orders allowed")),
          );
          return;
        }
      }

      final order = Order(
        id: DateTime.now().toString(),
        tableNumber: widget.tableNo,
        items: widget.cartItems,
        time: DateTime.now(),
        sessionId: sessionId,
        orderNo: orderNo,
      );

      await FirestoreService().addOrder(order);

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isPlacing = false;
      });
    }
  }
}
