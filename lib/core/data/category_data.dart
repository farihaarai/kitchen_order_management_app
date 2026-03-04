import 'package:kitchen_order_mgmt_app/enums/menu_category.dart';
import 'package:kitchen_order_mgmt_app/models/category_item.dart';

List<CategoryItem> categoryItems = [
  CategoryItem(
    category: MenuCategory.starters,
    title: "Starters",
    image: "assets/starters/lollipop.jpg",
  ),
  CategoryItem(
    category: MenuCategory.curries,
    title: "Curries",
    image: "assets/curries/butter_chicken.jpg",
  ),
  CategoryItem(
    category: MenuCategory.breads,
    title: "Breads",
    image: "assets/breads/garlic_naan.jpg",
  ),
  CategoryItem(
    category: MenuCategory.biryani,
    title: "Biryani",
    image: "assets/biryani/chicken_biryani.jpg",
  ),
  CategoryItem(
    category: MenuCategory.beverages,
    title: "Beverages",
    image: "assets/beverages/lemonade.jpg",
  ),
  CategoryItem(
    category: MenuCategory.deserts,
    title: "Deserts",
    image: "assets/deserts/gulabjamun.jpg",
  ),
];
