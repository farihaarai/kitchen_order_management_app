import 'package:kitchen_order_mgmt_app/enums/food_type.dart';

class MenuItem {
  final String id;
  final String name;
  final double price;
  final FoodType type;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
  });
}
