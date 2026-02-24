import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/active_orders_tab.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/completed_orders_tab.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Orders"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Active Orders"),
              Tab(text: "Completed Orders"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ActiveOrdersTab(), CompletedOrdersTab()],
        ),
      ),
    );
  }
}
