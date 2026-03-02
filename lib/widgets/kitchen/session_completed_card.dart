import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';

class SessionCompletedCard extends StatelessWidget {
  final String sessionId; // Unique session identifier
  final List<QueryDocumentSnapshot> docs; // All READY orders of this session

  const SessionCompletedCard({
    super.key,
    required this.sessionId,
    required this.docs,
  });

  @override
  Widget build(BuildContext context) {
    // All orders in this session belong to the same table
    final firstData = docs.first.data() as Map<String, dynamic>;
    final tableNo = firstData['tableNumber'];

    // ------------------------------------------------------------
    // Combine items from multiple orders
    // ------------------------------------------------------------
    Map<String, Map<String, dynamic>> combined = {};
    double total = 0;

    // Loop through each order
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final items = (data['items'] as List?) ?? [];

      // Loop through items inside the order
      for (var item in items) {
        final name = item['name'];
        final price = (item['price'] as num).toDouble();
        final qty = (item['quantity'] as num).toInt();

        // Combine quantities for same item
        if (combined.containsKey(name)) {
          combined[name]!['quantity'] += qty;
        } else {
          combined[name] = {'price': price, 'quantity': qty};
        }

        // Add to session total
        total += price * qty;
      }
    }

    // ------------------------------------------------------------
    // UI Card
    // ------------------------------------------------------------
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table number header
            Text(
              "Table $tableNo",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Combined item list
            ...combined.entries.map((entry) {
              final name = entry.key;
              final qty = entry.value['quantity'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("$name x$qty"),
              );
            }),

            const SizedBox(height: 6),

            // Session total amount
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Total: ₹ ${total.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // ------------------------------------------------------------
            // MARK PAID BUTTON
            // ------------------------------------------------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  FirestoreService().markSessionPaid(sessionId);
                },
                child: const Text(
                  "MARK PAID",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
