import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';
import 'package:kitchen_order_mgmt_app/widgets/kitchen/session_completed_card.dart';

class CompletedOrdersTab extends StatelessWidget {
  const CompletedOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, List<QueryDocumentSnapshot>>>(
      stream: FirestoreService().getReadySessions(),

      builder: (context, snapshot) {
        // If there is any error
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // If no data or no ready sessions
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No completed sessions"));
        }

        // Data format:
        // { sessionId : [orderDocs] }
        final sessions = snapshot.data!;

        // Convert map to list so it can be shown in ListView
        final sessionList = sessions.entries.toList();

        return ListView.builder(
          itemCount: sessionList.length,
          itemBuilder: (context, index) {
            // Each entry represents one session
            final sessionId = sessionList[index].key;
            final docs = sessionList[index].value;

            return SessionCompletedCard(sessionId: sessionId, docs: docs);
          },
        );
      },
    );
  }
}
