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
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    item.image,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "₹${item.price.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // IMPORTANT
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: quantity == 0 ? null : onDecrease,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: onIncrease,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
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
