import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/enums/food_type.dart';

class VegFilter extends StatelessWidget {
  final FoodType? selectedType;
  final Function(FoodType?) onchanged;

  const VegFilter({super.key, this.selectedType, required this.onchanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text("All"),
            selected: selectedType == null,
            onSelected: (_) => onchanged(null),
            selectedColor: Colors.green.shade100,
            backgroundColor: Colors.grey.shade200,
            shape: StadiumBorder(),
          ),

          SizedBox(width: 10),

          ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 15, color: Colors.green),
                SizedBox(width: 4),
                Text("Veg"),
              ],
            ),
            selected: selectedType == FoodType.veg,
            onSelected: (_) => onchanged(FoodType.veg),
            selectedColor: Colors.green.shade100,
            backgroundColor: Colors.grey.shade200,
            shape: StadiumBorder(),
          ),

          SizedBox(width: 10),

          ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 15, color: Colors.red),
                SizedBox(width: 4),
                Text("Non-Veg"),
              ],
            ),
            selected: selectedType == FoodType.nonVeg,
            onSelected: (_) => onchanged(FoodType.nonVeg),
            selectedColor: Colors.green.shade100,
            backgroundColor: Colors.grey.shade200,
            shape: StadiumBorder(),
          ),
        ],
      ),
    );
  }
}
