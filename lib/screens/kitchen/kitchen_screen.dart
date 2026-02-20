import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_bloc.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_event.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_state.dart';
import 'package:kitchen_order_mgmt_app/enums/order_status.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Orders")),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          final orders = state.orders;

          if (orders.isEmpty) {
            return Center(child: Text("No orders"));
          } else {
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Table ${order.tableNumber}"),
                            Spacer(),
                            Text(
                              "Time: ${order.time.hour}:${order.time.minute.toString().padLeft(2, '0')}",
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        ...order.items.map((cartItem) {
                          return Text(
                            "• ${cartItem.item.name} x${cartItem.quantity}",
                          );
                        }),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              order.status == OrderStatus.pending
                                  ? "Status: Pending"
                                  : "Status: Preparing",
                            ),
                            Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                order.status == OrderStatus.pending
                                    ? context.read<OrderBloc>().add(
                                        StartPreparing(order: order),
                                      )
                                    : context.read<OrderBloc>().add(
                                        MarkOrderReady(order: order),
                                      );
                              },
                              child: Text(
                                order.status == OrderStatus.pending
                                    ? "Start Preparing"
                                    : "Mark Ready",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
