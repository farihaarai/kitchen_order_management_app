import 'package:kitchen_order_mgmt_app/enums/food_type.dart';
import 'package:kitchen_order_mgmt_app/enums/menu_category.dart';

class MenuItem {
  final String id;
  final String name;
  final double price;
  final MenuCategory category;
  final FoodType type;
  final String image;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.image,
    required this.category,
  });
}
