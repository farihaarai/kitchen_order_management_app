import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_bloc.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_state.dart';
import 'package:kitchen_order_mgmt_app/core/data/menu_data.dart';
import 'package:kitchen_order_mgmt_app/enums/order_status.dart';
import 'package:kitchen_order_mgmt_app/models/cart_item.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/order_summary_screen.dart';
import 'package:kitchen_order_mgmt_app/widgets/menu_item_tile.dart';

class CustomerScreen extends StatefulWidget {
  final int tableNo;
  const CustomerScreen({super.key, required this.tableNo});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  Map<String, int> quantities = {};
  // bool showReadyBar = false;
  int getQuantity(String id) {
    return quantities[id] ?? 0;
  }

  int getTotalItems() {
    int total = 0;
    for (var qty in quantities.values) {
      total += qty;
    }
    return total;
  }

  void increase(String id) {
    final currentQty = quantities[id] ?? 0;
    quantities[id] = currentQty + 1;
    setState(() {});
  }

  void decrease(String id) {
    final currentQty = quantities[id] ?? 0;
    if (currentQty > 1) {
      quantities[id] = currentQty - 1;
    } else {
      quantities.remove(id); // remove when 0
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        OrderStatus? tableStatus;

        final tableOrders = state.orders
            .where((order) => order.tableNumber == widget.tableNo)
            .toList();

        if (tableOrders.isNotEmpty) {
          // Get latest order of this table
          tableOrders.sort((a, b) => b.time.compareTo(a.time));
          tableStatus = tableOrders.first.status;
        }
        return Scaffold(
          appBar: AppBar(title: Text("Menu")),
          body: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Text("Table No.: ${widget.tableNo}"),
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];

                      return MenuItemTile(
                        item: item,
                        quantity: getQuantity(item.id),
                        onIncrease: () => increase(item.id),
                        onDecrease: () => decrease(item.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: tableStatus == OrderStatus.ready
              ? readyBar()
              : tableStatus == OrderStatus.preparing
              ? preparingBar()
              : quantities.isNotEmpty
              ? viewOrderBar()
              : null,
        );
      },
    );
  }

  Widget preparingBar() {
    return Container(
      height: 60,
      color: Colors.orange,
      child: Center(
        child: Text(
          "Your order is being prepared",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget readyBar() {
    return Container(
      height: 60,
      color: Colors.green,
      child: Center(
        child: Text(
          "Order is ready",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget viewOrderBar() {
    final totalItems = getTotalItems();

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[300],
      child: Row(
        children: [
          totalItems == 1
              ? Text("1 item added")
              : Text("$totalItems items added"),

          Spacer(),
          ElevatedButton(
            onPressed: () async {
              final cartItems = buildCartItems();
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderSummaryScreen(
                    tableNo: widget.tableNo,
                    cartItems: cartItems,
                  ),
                ),
              );
              if (result == true) {
                setState(() {
                  quantities.clear();
                  // showReadyBar = true;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text("View Order"),
          ),
        ],
      ),
    );
  }

  List<CartItem> buildCartItems() {
    List<CartItem> cart = [];

    for (var item in menuItems) {
      final qty = quantities[item.id] ?? 0;

      if (qty > 0) {
        cart.add(CartItem(item: item, quantity: qty));
      }
    }
    return cart;
  }
}
