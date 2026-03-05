import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';

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
      body: StreamBuilder<Map<String, Map<String, dynamic>>>(
        stream: FirestoreService().getSessionCombinedItems(tableNo),

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
          final items = snapshot.data!;

          // If no active session (all orders paid)
          if (items.isEmpty) {
            return const Center(child: Text("No active session"));
          }

          // Calculate total amount
          double total = 0;
          for (var item in items.values) {
            total += item['price'] * item['quantity'];
          }

          // ------------------------------------------------------------
          // Receipt UI
          // ------------------------------------------------------------
          return Padding(
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
                        ...items.entries.map((entry) {
                          final name = entry.key;
                          final price = entry.value['price'];
                          final qty = entry.value['quantity'];
                          final itemTotal = price * qty;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(child: Text(name)),
                                Text("Qty: $qty"),
                                const SizedBox(width: 10),
                                Text("₹ ${itemTotal.toStringAsFixed(0)}"),
                              ],
                            ),
                          );
                        }),

                        const Divider(),

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
          );
        },
      ),
    );
  }
}
