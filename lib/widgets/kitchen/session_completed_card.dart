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

    final entries = combined.entries.toList();
    final visibleItems = entries.take(5).toList();
    final remaining = entries.length - visibleItems.length;

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
            ...visibleItems.map((entry) {
              final name = entry.key;
              final qty = entry.value['quantity'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("$name x$qty"),
              );
            }),

            if (remaining > 0)
              GestureDetector(
                onTap: () {
                  _showFullSession(context, tableNo, combined);
                },
                child: Text(
                  "+$remaining more",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const Spacer(),

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

  void _showFullSession(
    BuildContext context,
    int tableNo,
    Map<String, Map<String, dynamic>> combined,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// HEADER
                Row(
                  children: [
                    const Icon(
                      Icons.table_restaurant,
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),
                    const SizedBox(width: 8),

                    Text(
                      "Table $tableNo",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const Divider(),

                const SizedBox(height: 8),

                /// ITEM LIST
                ...combined.entries.map((entry) {
                  final name = entry.key;
                  final qty = entry.value['quantity'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "x$qty",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                /// FOOTER BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "CLOSE",
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
      },
    );
  }
}
