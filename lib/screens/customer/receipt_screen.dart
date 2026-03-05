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
      appBar: AppBar(
        title: Text("Receipt"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _buildReceiptContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "ROYAL SPICE",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text("Table No: $tableNo", style: const TextStyle(fontSize: 16)),
        Text(
          "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 1),
        _buildItemList(),
        const Divider(thickness: 1),

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

        Text("Please pay at counter", style: TextStyle(color: Colors.grey)),
        SizedBox(height: 10),
        Text("Thank you!", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildItemList() {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: items.map((cartItem) {
        final itemTotal = cartItem.item.price * cartItem.quantity;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(cartItem.item.name)),
              Text("Qty: ${cartItem.quantity}"),
              SizedBox(width: 10),
              Text("₹ ${itemTotal.toStringAsFixed(0)}"),
            ],
          ),
        );
      }).toList(),
    );
  }
}
