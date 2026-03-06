import 'package:flutter/material.dart';
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
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// FOOD IMAGE
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: AspectRatio(
                aspectRatio: 1.4,
                child: Image.asset(
                  item.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),

          /// FOOD INFO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// NAME
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                /// PRICE
                Text(
                  "₹${item.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                /// ADD / REMOVE BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// Veg / Non veg indicator
                    // Container(
                    //   width: 12,
                    //   height: 12,
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     color: item.type.name == "veg"
                    //         ? Colors.green
                    //         : Colors.red,
                    //   ),
                    // ),

                    /// Quantity buttons
                    quantity == 0
                        ? ElevatedButton(
                            onPressed: onIncrease,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2E7D32),
                              side: const BorderSide(color: Color(0xFF2E7D32)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              minimumSize: const Size(52, 28),
                            ),
                            child: const Text(
                              "ADD",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF2E7D32),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: onDecrease,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.remove, size: 16),
                                  ),
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(width: 4),

                                GestureDetector(
                                  onTap: onIncrease,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.add, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
