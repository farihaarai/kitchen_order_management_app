import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/order_service.dart';

class SessionReceiptScreen extends StatelessWidget {
  final int tableNo; // Table number for which receipt is shown

  const SessionReceiptScreen({super.key, required this.tableNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      // Listen to combined session items in real-time
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: OrderService().getSessionOrders(tableNo),

        builder: (context, snapshot) {
          // Show loading while data is fetching
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Map format:
          // {
          //   "Burger": {price: 120, quantity: 3},
          //   "Pizza": {price: 250, quantity: 1}
          // }
          final orders = snapshot.data!;

          // sort orders by orderNo
          orders.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aNo = (aData['orderNo'] ?? 0) as int;
            final bNo = (bData['orderNo'] ?? 0) as int;

            return aNo.compareTo(bNo);
          });

          // If no active session (all orders paid)
          if (orders.isEmpty) {
            return const Center(child: Text("No active session"));
          }

          // Calculate total amount
          double total = 0;

          for (var doc in orders) {
            final data = doc.data() as Map<String, dynamic>;
            final items = (data['items'] as List?) ?? [];

            for (var item in items) {
              total +=
                  (item['price'] as num).toDouble() *
                  (item['quantity'] as num).toInt();
            }
          }

          // ------------------------------------------------------------
          // Receipt UI
          // ------------------------------------------------------------
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  // Limit width for web/tablet
                  constraints: const BoxConstraints(maxWidth: 400),

                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Restaurant title
                          const Text(
                            "ROYAL SPICE",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Table number
                          Text("Table No: $tableNo"),

                          const SizedBox(height: 10),
                          const Divider(),

                          // ------------------------------------------------
                          // Item list (combined from multiple orders)
                          // ------------------------------------------------
                          ...orders.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final orderNo = data['orderNo'];
                            final items = (data['items'] as List?) ?? [];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),

                                Text(
                                  "Order #$orderNo",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: const [
                                    Expanded(
                                      child: Text(
                                        "Item",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        "Qty",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        "Amt",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(),

                                ...items.map((item) {
                                  final name = item['name'];
                                  final price = (item['price'] as num)
                                      .toDouble();
                                  final qty = (item['quantity'] as num).toInt();
                                  final itemTotal = price * qty;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        // Item column
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),

                                        // Qty column (fixed width)
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            "$qty",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),

                                        // Amount column (fixed width)
                                        SizedBox(
                                          width: 70,
                                          child: Text(
                                            "₹${itemTotal.toStringAsFixed(0)}",
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                const Divider(),
                                const SizedBox(height: 6),
                              ],
                            );
                          }),

                          const SizedBox(height: 10),

                          // Total amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "₹ ${total.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Payment instruction
                          const Text(
                            "Please pay at counter",
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Thank you!",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
