import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';
import 'package:kitchen_order_mgmt_app/widgets/admin/metric_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f7fa),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metrics
            const Text(
              "Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.7,
              children: [
                StreamBuilder<double>(
                  stream: FirestoreService().getSalesToday(),
                  builder: (context, snapshot) {
                    final sales = snapshot.data ?? 0;

                    return MetricCard(
                      title: "Sales Today",
                      value: "₹${sales.toStringAsFixed(0)}",
                      icon: Icons.payments,
                      color: Colors.green,
                    );
                  },
                ),

                StreamBuilder<int>(
                  stream: FirestoreService().getOrdersToday(),
                  builder: (context, snapshot) {
                    final orders = snapshot.data ?? 0;

                    return MetricCard(
                      title: "Orders Today",
                      value: orders.toString(),
                      icon: Icons.receipt_long,
                      color: Colors.blue,
                    );
                  },
                ),

                StreamBuilder<int>(
                  stream: FirestoreService().getActiveTables(),
                  builder: (context, snapshot) {
                    final tables = snapshot.data ?? 0;

                    return MetricCard(
                      title: "Active Tables",
                      value: tables.toString(),
                      icon: Icons.table_restaurant,
                      color: Colors.orange,
                    );
                  },
                ),

                StreamBuilder<int>(
                  stream: FirestoreService().getCompletedSessions(),
                  builder: (context, snapshot) {
                    final sessions = snapshot.data ?? 0;

                    return MetricCard(
                      title: "Sessions",
                      value: sessions.toString(),
                      icon: Icons.groups,
                      color: Colors.purple,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// SALES CHART
            const Text(
              "Sales Today",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Center(child: Text("Sales Chart Coming Soon")),
            ),

            const SizedBox(height: 30),

            /// TOP ITEMS
            const Text(
              "Top Selling Items",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _buildTopItem("Paneer Butter Masala", "45 orders"),
            _buildTopItem("Garlic Naan", "38 orders"),
            _buildTopItem("Chicken Biryani", "31 orders"),

            const SizedBox(height: 30),

            /// RECENT SESSIONS
            const Text(
              "Recent Sessions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _buildSession("Table 4", "₹760"),
            _buildSession("Table 2", "₹450"),
            _buildSession("Table 7", "₹920"),
          ],
        ),
      ),
    );
  }

  Widget _buildTopItem(String name, String orders) {
    return Card(
      elevation: 0,
      child: ListTile(
        title: Text(name),
        trailing: Text(
          orders,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSession(String table, String amount) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.table_restaurant),
        title: Text(table),
        trailing: Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
