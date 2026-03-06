import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';
import 'package:kitchen_order_mgmt_app/widgets/kitchen/order_card.dart';

class ActiveOrdersTab extends StatefulWidget {
  const ActiveOrdersTab({super.key});

  @override
  State<ActiveOrdersTab> createState() => _ActiveOrdersTabState();
}

class _ActiveOrdersTabState extends State<ActiveOrdersTab> {
  final AudioPlayer player = AudioPlayer();

  int _previousOrderCount = 0;
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

        // play sound when new order arrives
        if (orders.length > _previousOrderCount) {
          player.play(AssetSource('sounds/order.mp3'));
        }

        // update count
        _previousOrderCount = orders.length;

        // If no active orders
        if (orders.isEmpty) {
          return const Center(child: Text("No active orders"));
        }

        // Show orders in a list
        return LayoutBuilder(
          builder: (context, constraints) {
            int columns = 1;

            if (constraints.maxWidth > 1200) {
              columns = 3;
            } else if (constraints.maxWidth > 700) {
              columns = 2;
            }

            return AnimatedSwitcher(
              duration: Duration(seconds: 1),
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return OrderCard(doc: orders[index]);
                },
              ),
            );
          },
        );
      },
    );
  }
}
