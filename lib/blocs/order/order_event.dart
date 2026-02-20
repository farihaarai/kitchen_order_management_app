import 'package:kitchen_order_mgmt_app/models/order.dart';

abstract class OrderEvent {}

class PlaceOrder extends OrderEvent {
  final Order order;

  PlaceOrder({required this.order});
}

class StartPreparing extends OrderEvent {
  final Order order;

  StartPreparing({required this.order});
}

class MarkOrderReady extends OrderEvent {
  final Order order;

  MarkOrderReady({required this.order});
}
