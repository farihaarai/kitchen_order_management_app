import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/models/cart_item.dart';

class ReceiptScreen extends StatelessWidget {
  final List<CartItem> items;
  final int tableNo;
  final DateTime time;

  const ReceiptScreen({
    super.key,
    required this.items,
    required this.tableNo,
    required this.time,
  });

  double getTotal() {
    double total = 0;

    for (var item in items) {
      total += item.item.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bill / Receipt")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Table No: $tableNo",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}",
            ),
            const Divider(height: 30),
            Expanded(
              child: ListView(
                children: items.map((cartItem) {
                  final itemTotal = cartItem.item.price * cartItem.quantity;

                  return ListTile(
                    title: Text(cartItem.item.name),
                    subtitle: Text("Qty: ${cartItem.quantity}"),
                    trailing: Text("₹ ${itemTotal.toStringAsFixed(0)}"),
                  );
                }).toList(),
              ),
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹ ${getTotal().toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                "Please pay at counter",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
