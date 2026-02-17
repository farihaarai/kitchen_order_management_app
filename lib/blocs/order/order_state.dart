import 'package:kitchen_order_mgmt_app/models/order.dart';

class OrderState {
  final List<Order> orders;

  OrderState({required this.orders});

  factory OrderState.initial() {
    return OrderState(orders: []);
  }
}
