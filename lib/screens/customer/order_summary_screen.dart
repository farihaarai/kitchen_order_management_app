import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_bloc.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_event.dart';
import 'package:kitchen_order_mgmt_app/models/cart_item.dart';
import 'package:kitchen_order_mgmt_app/models/order.dart';

class OrderSummaryScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final int tableNo;

  const OrderSummaryScreen({
    super.key,
    required this.cartItems,
    required this.tableNo,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  double getTotalAmount() {
    double total = 0;

    for (var cartItem in widget.cartItems) {
      total += cartItem.item.price * cartItem.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Order")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    title: Text(item.item.name),
                    trailing: Text("${item.item.price} x ${item.quantity}"),
                  );
                },
              ),
            ),
            Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹ ${getTotalAmount().toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: placeOrder,

            child: Text("Place Order"),
          ),
        ),
      ),
    );
  }

  void placeOrder() {
    final order = Order(
      id: DateTime.now().toString(),
      tableNumber: widget.tableNo,
      items: widget.cartItems,
      time: DateTime.now(),
    );
    context.read<OrderBloc>().add(PlaceOrder(order));
    Navigator.pop(context, true);
    print("Order Placed");
  }
}
