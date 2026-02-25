import 'package:kitchen_order_mgmt_app/enums/menu_category.dart';
import 'package:kitchen_order_mgmt_app/models/category_item.dart';

List<CategoryItem> categoryItems = [
  CategoryItem(
    category: MenuCategory.snacks,
    title: "Snacks",
    image: "assets/snacks.jpg",
  ),
  CategoryItem(
    category: MenuCategory.pizza,
    title: "Pizza",
    image: "assets/pizza.jpg",
  ),
  CategoryItem(
    category: MenuCategory.mainCourse,
    title: "Main Course",
    image: "assets/main_course.jpg",
  ),
  CategoryItem(
    category: MenuCategory.beverages,
    title: "Beverages",
    image: "assets/beverages.jpg",
  ),
];
