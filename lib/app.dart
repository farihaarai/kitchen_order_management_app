import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_bloc.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_event.dart';
import 'package:kitchen_order_mgmt_app/core/data/menu_data.dart';
import 'package:kitchen_order_mgmt_app/models/cart_item.dart';
import 'package:kitchen_order_mgmt_app/models/order.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/customer_screen.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/table_entry_screen.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/kitchen_screen.dart';

class KitchenOrderMgmt extends StatelessWidget {
  const KitchenOrderMgmt({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = OrderBloc();

        // Add dummy orders
        bloc.add(
          PlaceOrder(
            order: Order(
              id: "1",
              tableNumber: 3,
              items: [
                CartItem(item: menuItems[0], quantity: 2),
                CartItem(item: menuItems[6], quantity: 1),
              ],
              time: DateTime.now(),
            ),
          ),
        );

        bloc.add(
          PlaceOrder(
            order: Order(
              id: "2",
              tableNumber: 5,
              items: [CartItem(item: menuItems[1], quantity: 1)],
              time: DateTime.now(),
            ),
          ),
        );

        return bloc;
      },
      child: MaterialApp(home: KitchenScreen()),
    );
  }
}
