import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/enums/food_type.dart';
import 'package:kitchen_order_mgmt_app/models/menu_item.dart';

class MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const MenuItemTile({
    super.key,
    required this.item,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  item.image,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 8),

                // Icon(
                //   Icons.circle,
                //   color: item.type == FoodType.veg ? Colors.green : Colors.red,
                // ),
                // SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Text("₹ ${item.price.toStringAsFixed(0)}"),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: quantity == 0 ? null : onDecrease,

                            icon: Icon(Icons.remove),
                          ),
                          SizedBox(width: 4),
                          Text(
                            quantity.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          IconButton(
                            onPressed: onIncrease,
                            icon: Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
