import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/active_orders_tab.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/completed_orders_tab.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/paid_orders_tab.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 2,
          title: const Text(
            "Kitchen Orders",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white30,
            indicatorWeight: 4,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: [
              Tab(icon: Icon(Icons.kitchen), text: "Active"),
              Tab(icon: Icon(Icons.check_circle), text: "Completed"),
              Tab(icon: Icon(Icons.attach_money_rounded), text: "Paid"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ActiveOrdersTab(), CompletedOrdersTab(), PaidOrdersTab()],
        ),
      ),
    );
  }
}
