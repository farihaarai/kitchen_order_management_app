import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders"));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
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
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Table $tableNumber"),
                          const Spacer(),
                          Text(
                            time != null
                                ? "Time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}"
                                : "Time: --:--",
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Items
                      ...items.map((item) {
                        final qty = (item['quantity'] as num?)?.toInt() ?? 0;
                        return Text("• ${item['name']} x$qty");
                      }),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Text("Status: ${status.toString().toUpperCase()}"),
                          const Spacer(),

                          if (status == 'pending')
                            ElevatedButton(
                              onPressed: () {
                                FirestoreService().updateOrderStatus(
                                  docId,
                                  'preparing',
                                );
                                print("Updating doc: $docId");
                              },
                              child: const Text("Start Preparing"),
                            )
                          else if (status == "preparing")
                            ElevatedButton(
                              onPressed: () {
                                FirestoreService().updateOrderStatus(
                                  docId,
                                  'ready',
                                );
                                print("Updating doc: $docId");
                              },
                              child: const Text("Mark Ready"),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
