import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/active_orders_tab.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/completed_orders_tab.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/paid_orders_tab.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';

// Main Kitchen Dashboard Screen
// Shows 3 tabs:
// 1. Active Orders (pending + preparing)
// 2. Completed Sessions (ready)
// 3. Paid Sessions

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // Total number of tabs
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // App theme color
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 2,

          // Screen title
          title: const Text(
            "Kitchen Orders",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          // Tab bar inside AppBar
          bottom: TabBar(
            indicatorColor: Colors.white, // active tab underline color
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white30,
            indicatorWeight: 4,

            // Active tab text style
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),

            // Inactive tab text style
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),

            tabs: [
              // -------------------------------
              // Active Orders Tab
              // Shows number of orders which are
              // pending or preparing
              // -------------------------------
              StreamBuilder<int>(
                stream: FirestoreService().getActiveOrdersCount(),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;

                  return Tab(
                    icon: const Icon(Icons.kitchen),
                    text: "Active ($count)",
                  );
                },
              ),

              // -------------------------------
              // Completed Tab
              // Shows sessions where orders are READY
              // Count is based on unique sessionId
              // -------------------------------
              StreamBuilder<int>(
                stream: FirestoreService().getReadySessionsCount(),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;

                  return Tab(
                    icon: const Icon(Icons.check_circle),
                    text: "Completed ($count)",
                  );
                },
              ),

              // -------------------------------
              // Paid Tab
              // Shows sessions where payment is done
              // Count is based on unique sessionId
              // -------------------------------
              StreamBuilder<int>(
                stream: FirestoreService().getPaidSessionsCount(),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;

                  return Tab(
                    icon: const Icon(Icons.attach_money_rounded),
                    text: "Paid ($count)",
                  );
                },
              ),
            ],
          ),
        ),

        // -------------------------------
        // Tab Views
        // Each tab loads its own screen
        // -------------------------------
        body: const TabBarView(
          children: [
            // Tab 1 - Active orders list
            ActiveOrdersTab(),

            // Tab 2 - Ready sessions grouped by sessionId
            CompletedOrdersTab(),

            // Tab 3 - Paid sessions grouped by sessionId
            PaidOrdersTab(),
          ],
        ),
      ),
    );
  }
}
