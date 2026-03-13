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
  Future<bool> confirmPlaceOrder() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Order"),
          content: Text("Are you sure you want to place this order?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text(
                "Place Order",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  bool _isPlacing = false; // Prevent multiple clicks

  void clearCart() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clear Cart"),
          content: const Text("Remove all items from the cart?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Clear",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirestoreService().clearCart(widget.tableNo);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

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

        actions: [
          IconButton(
            onPressed: clearCart,
            icon: Icon(Icons.remove_shopping_cart_rounded),
            tooltip: "Clear Cart",
          ),
        ],
      ),

      // ---------------- Order Items ----------------
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // List of selected items
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getCartStream(widget.tableNo),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  double total = 0;

                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final price = (data['price'] as num).toDouble();
                    final qty = (data['quantity'] as num).toInt();

                    total += price * qty;
                  }

                  if (docs.isEmpty) {
                    return const Center(child: Text("Cart is empty"));
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;

                            final name = data['name'];
                            final price = (data['price'] as num).toDouble();
                            final qty = (data['quantity'] as num).toInt();

                            final itemTotal = price * qty;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    /// ITEM NAME
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),

                                    /// QUANTITY
                                    Row(
                                      children: [
                                        /// DECREASE BUTTON
                                        InkWell(
                                          onTap: () async {
                                            await FirestoreService()
                                                .decreaseCartItem(
                                                  widget.tableNo,
                                                  data['id'],
                                                );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        /// QUANTITY
                                        Text(
                                          qty.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        /// INCREASE BUTTON
                                        InkWell(
                                          onTap: () async {
                                            await FirestoreService()
                                                .addToCart(widget.tableNo, {
                                                  "id": data['id'],
                                                  "name": name,
                                                  "price": price,
                                                });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 18,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(width: 12),

                                    /// PRICE
                                    Text(
                                      "₹${itemTotal.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF2E7D32),
                                      ),
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
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Amount",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "₹ ${total.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ---------------- Bottom Button ----------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _isPlacing
                ? null
                : () async {
                    bool confirmed = await confirmPlaceOrder();
                    if (confirmed) {
                      placeOrder();
                    }
                  },
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
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

      // Active orders = status not paid (same session) && not a redo order
      final activeOrders = snapshot.docs.where((doc) {
        final status = doc['status'];
        final isRedo = doc.data()['isRedo'] ?? false;

        return status != 'paid' && isRedo == false;
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
      await FirestoreService().clearCart(widget.tableNo);

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isPlacing = false;
      });
    }
  }
}
