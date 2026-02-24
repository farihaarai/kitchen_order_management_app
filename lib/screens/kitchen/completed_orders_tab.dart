import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';
import 'package:kitchen_order_mgmt_app/widgets/kitchen/order_card.dart';

class CompletedOrdersTab extends StatelessWidget {
  const CompletedOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getCompletedOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return const Center(child: Text("No completed orders"));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderCard(doc: orders[index], isCompleted: true);
          },
        );
      },
    );
  }
}
