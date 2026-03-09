import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SessionPaidCard extends StatelessWidget {
  final String sessionId; // Unique session id
  final List<QueryDocumentSnapshot> docs; // All orders of this session

  const SessionPaidCard({
    super.key,
    required this.sessionId,
    required this.docs,
  });

  @override
  Widget build(BuildContext context) {
    // Get table number from first order (all orders have same table)
    final firstData = docs.first.data() as Map<String, dynamic>;
    final tableNo = firstData['tableNumber'];

    // Map to combine same items across multiple orders
    Map<String, int> combined = {};

    // Total amount for the whole session
    double total = 0;

    // Loop through each order in this session
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final items = (data['items'] as List?) ?? [];

      // Loop through items of the order
      for (var item in items) {
        final name = item['name'];
        final price = (item['price'] as num).toDouble();
        final qty = (item['quantity'] as num).toInt();

        // Combine quantity if item already exists
        combined[name] = (combined[name] ?? 0) + qty;

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table number
            Text(
              "Table $tableNo",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // Combined item list
            ...combined.entries.map((e) => Text("${e.key} x${e.value}")),

            const SizedBox(height: 6),

            // Total paid amount
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Paid: ₹ ${total.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
