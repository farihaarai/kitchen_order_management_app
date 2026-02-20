import 'package:kitchen_order_mgmt_app/enums/order_status.dart';
import 'package:kitchen_order_mgmt_app/models/cart_item.dart';

class Order {
  final String id;
  final int tableNumber;
  final List<CartItem> items;
  final DateTime time;
  OrderStatus status;

  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.time,
    this.status = OrderStatus.pending,
  });
}
