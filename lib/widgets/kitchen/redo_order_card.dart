import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RedoOrderCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const RedoOrderCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;

    final tableNumber = (data['tableNumber'] as num?)?.toInt() ?? 0;
    final status = data['status'];

    final items = (data['items'] as List?) ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Table $tableNumber",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "REDO",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ...items.map((item) {
              final qty = (item['quantity'] as num?)?.toInt() ?? 0;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  "${item['name']} x$qty",
                  style: TextStyle(fontSize: 15),
                ),
              );
            }),

            const SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status.toString().toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
