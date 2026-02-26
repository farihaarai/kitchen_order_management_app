import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final bool isCompleted;
  const OrderCard({super.key, this.isCompleted = false, required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final docId = doc.id;
    final status = data['status'];
    final tableNumber = (data['tableNumber'] as num?)?.toInt() ?? 0;

    final items = (data['items'] as List?) ?? [];

    final Timestamp? ts = data['time'] is Timestamp
        ? data['time'] as Timestamp
        : null;
    final DateTime? time = ts?.toDate();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Table $tableNumber",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  time != null
                      ? "${time.hour}:${time.minute.toString().padLeft(2, '0')}"
                      : "--:--",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Items in order
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                final qty = (item['quantity'] as num?)?.toInt() ?? 0;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "${item['name']} x$qty",
                    style: TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: status == 'pending'
                    ? Colors.red.shade100
                    : status == 'preparing'
                    ? Colors.orange.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status.toString().toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: status == 'pending'
                      ? Colors.red
                      : status == 'preparing'
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ),

            SizedBox(height: 10),

            if (!isCompleted && status == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    FirestoreService().updateOrderStatus(docId, 'preparing');
                    print("Updating doc: $docId");
                  },
                  child: const Text(
                    "START PREPARING",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else if (!isCompleted && status == "preparing")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    FirestoreService().updateOrderStatus(docId, 'ready');
                    print("Updating doc: $docId");
                  },
                  child: const Text(
                    "MARK READY",
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
