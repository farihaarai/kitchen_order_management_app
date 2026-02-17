import 'package:kitchen_order_mgmt_app/models/order.dart';

abstract class OrderEvent {}

class PlaceOrder extends OrderEvent {
  final Order order;

  PlaceOrder(this.order);
}
