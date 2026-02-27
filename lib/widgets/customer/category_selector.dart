import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/core/data/category_data.dart';
import 'package:kitchen_order_mgmt_app/enums/menu_category.dart';

class CategorySelector extends StatelessWidget {
  final MenuCategory selectedCategory;
  final Function(MenuCategory) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoryItems.length,
        itemBuilder: (context, index) {
          final category = categoryItems[index];
          bool isSelected = category.category == selectedCategory;

          return GestureDetector(
            onTap: () {
              onCategorySelected(category.category);
            },
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: const Color.fromARGB(255, 15, 190, 24),
                              width: 4,
                            )
                          : null,
                      image: DecorationImage(
                        image: AssetImage(category.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
