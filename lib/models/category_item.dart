import 'package:kitchen_order_mgmt_app/enums/menu_category.dart';

class CategoryItem {
  final MenuCategory category;
  final String title;
  final String image;

  CategoryItem({
    required this.category,
    required this.title,
    required this.image,
  });
}
