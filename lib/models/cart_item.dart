import 'package:kitchen_order_mgmt_app/models/menu_item.dart';

class CartItem {
  final MenuItem item;
  final int quantity;

  CartItem({required this.item, required this.quantity});
}
