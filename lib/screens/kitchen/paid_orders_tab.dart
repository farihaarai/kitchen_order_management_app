import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';
import 'package:kitchen_order_mgmt_app/widgets/kitchen/session_paid_card.dart';

class PaidOrdersTab extends StatelessWidget {
  const PaidOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, List<QueryDocumentSnapshot>>>(
      // Listen to paid sessions in real-time
      stream: FirestoreService().getPaidSessions(),

      builder: (context, snapshot) {
        // If no data OR no paid sessions
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No paid sessions"));
        }

        // Map format:
        // { sessionId : [orderDocs] }
        final sessions = snapshot.data!;

        // Convert map to list so we can show in ListView
        final sessionList = sessions.entries.toList();

        return ListView.builder(
          itemCount: sessionList.length,
          itemBuilder: (context, index) {
            // Each entry = one session
            final sessionId = sessionList[index].key;
            final docs = sessionList[index].value;

            return SessionPaidCard(sessionId: sessionId, docs: docs);
          },
        );
      },
    );
  }
}
