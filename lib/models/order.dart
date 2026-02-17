import 'package:kitchen_order_mgmt_app/models/menu_item.dart';

class Order {
  final String id;
  final int tableNumber;
  final List<MenuItem> items;
  final DateTime time;

  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.time,
  });
}
