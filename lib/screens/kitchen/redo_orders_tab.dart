import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/kitchen_service.dart';
import 'package:kitchen_order_mgmt_app/widgets/kitchen/redo_order_card.dart';

class RedoOrdersTab extends StatelessWidget {
  const RedoOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: KitchenService().getRedoOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No redo orders"));
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['isRedo'] == true
          // && data['status'] != 'paid'
          ;
        }).toList();

        docs.sort((a, b) {
          final ta = (a['time'] as Timestamp).toDate();
          final tb = (b['time'] as Timestamp).toDate();
          return tb.compareTo(ta); // newest first
        });

        if (docs.isEmpty) {
          return Center(child: Text("No redo orders"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return RedoOrderCard(doc: docs[index]);
          },
        );
      },
    );
  }
}
