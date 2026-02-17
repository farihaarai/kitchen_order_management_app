import 'package:kitchen_order_mgmt_app/enums/food_type.dart';
import 'package:kitchen_order_mgmt_app/models/menu_item.dart';

List<MenuItem> menuItems = [
  MenuItem(id: '1', name: 'Veg Burger', price: 120, type: FoodType.veg),
  MenuItem(id: '2', name: 'Chicken Burger', price: 160, type: FoodType.nonVeg),
  MenuItem(id: '3', name: 'Margherita Pizza', price: 250, type: FoodType.veg),
  MenuItem(id: '4', name: 'Chicken Pizza', price: 340, type: FoodType.nonVeg),
  MenuItem(id: '5', name: 'White Sauce Pasta', price: 180, type: FoodType.veg),
  MenuItem(id: '6', name: 'Grilled Chicken', price: 220, type: FoodType.nonVeg),
  MenuItem(id: '7', name: 'French Fries', price: 90, type: FoodType.veg),
  MenuItem(id: '8', name: 'Cold Coffee', price: 130, type: FoodType.veg),
  MenuItem(id: '9', name: 'Egg Sandwich', price: 110, type: FoodType.nonVeg),
  MenuItem(id: '10', name: 'Chocolate Shake', price: 140, type: FoodType.veg),
];
