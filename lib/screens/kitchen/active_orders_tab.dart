import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';
import 'package:kitchen_order_mgmt_app/widgets/kitchen/order_card.dart';

class ActiveOrdersTab extends StatelessWidget {
  const ActiveOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Listen to active orders in real-time
      stream: FirestoreService().getActiveOrdersStream(),

      builder: (context, snapshot) {
        // If any error occurs while fetching data
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Show loading indicator while data is loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // List of active order documents
        final orders = snapshot.data!.docs;

        // If no active orders
        if (orders.isEmpty) {
          return const Center(child: Text("No active orders"));
        }

        // Show orders in a list
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderCard(doc: orders[index]);
          },
        );
      },
    );
  }
}
