import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/core/data/menu_data.dart';
import 'package:kitchen_order_mgmt_app/enums/food_type.dart';
import 'package:kitchen_order_mgmt_app/enums/menu_category.dart';
import 'package:kitchen_order_mgmt_app/models/cart_item.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/order_summary_screen.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/receipt_screen.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';
import 'package:kitchen_order_mgmt_app/widgets/customer/category_selector.dart';
import 'package:kitchen_order_mgmt_app/widgets/customer/menu_item_tile.dart';
import 'package:kitchen_order_mgmt_app/widgets/customer/veg_filter.dart';

class CustomerScreen extends StatefulWidget {
  final int tableNo;
  const CustomerScreen({super.key, required this.tableNo});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  Map<String, int> quantities = {};
  String? _lastStatus;
  List<CartItem> _lastOrderItems = [];
  DateTime? _lastOrderTime;
  MenuCategory _selectedCategory = MenuCategory.snacks;
  FoodType? _selectedFoodType;

  int getQuantity(String id) {
    return quantities[id] ?? 0;
  }

  int getTotalItems() {
    int total = 0;
    for (var qty in quantities.values) {
      total += qty;
    }
    return total;
  }

  void increase(String id) {
    final currentQty = quantities[id] ?? 0;
    quantities[id] = currentQty + 1;
    setState(() {});
  }

  void decrease(String id) {
    final currentQty = quantities[id] ?? 0;
    if (currentQty > 1) {
      quantities[id] = currentQty - 1;
    } else {
      quantities.remove(id); // remove when 0
    }
    setState(() {});
  }

  double getTotalPrice() {
    double total = 0;

    for (var item in menuItems) {
      final qty = quantities[item.id] ?? 0;
      if (qty > 0) {
        total += item.price * qty;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = menuItems.where((item) {
      final categoryMatch = item.category == _selectedCategory;
      final typeMatch = _selectedFoodType == null
          ? true
          : item.type == _selectedFoodType;

      return categoryMatch && typeMatch;
    }).toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32), // deep food green
        foregroundColor: Colors.white,
        elevation: 3,
        centerTitle: false,
        titleSpacing: 12,
        title: Row(
          children: [
            const Icon(Icons.restaurant_rounded, size: 26),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Dine In",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Table ${widget.tableNo}",
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(height: 8),
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                  // _selectedFoodType = null; // reset filter when category change
                });
              },
            ),

            Divider(),

            VegFilter(
              selectedType: _selectedFoodType,
              onchanged: (type) {
                setState(() {
                  _selectedFoodType = type;
                });
              },
            ),

            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];

                  return MenuItemTile(
                    item: item,
                    quantity: getQuantity(item.id),
                    onIncrease: () => increase(item.id),
                    onDecrease: () => decrease(item.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildStatusBar(),
    );
  }

  Widget _buildStatusBar() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getOrdersForTable(widget.tableNo),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;

          // Find latest by time manually
          QueryDocumentSnapshot latestDoc = docs.first;
          Timestamp? latestTs = latestDoc['time'] as Timestamp?;

          for (var doc in docs) {
            final ts = doc['time'] as Timestamp?;

            // Skip docs without time
            if (ts == null) continue;

            if (latestTs == null || ts.toDate().isAfter(latestTs.toDate())) {
              latestDoc = doc;
              latestTs = ts;
            }
          }

          final data = latestDoc.data() as Map<String, dynamic>;
          _lastStatus = data['status'];

          final Timestamp? ts = data['time'] as Timestamp?;
          _lastOrderTime = ts?.toDate();

          final items = (data['items'] as List?) ?? [];

          _lastOrderItems = items.map((item) {
            return CartItem(
              item: menuItems.firstWhere((m) => m.id == item['id']),
              quantity: (item['quantity'] as num).toInt(),
            );
          }).toList();

          print("Latest doc used: ${latestDoc.id} → $_lastStatus");
        }

        // Use cached status if snapshot temporarily empty
        final tableStatus = _lastStatus;

        if (tableStatus == 'ready') {
          return readyBar();
        }

        if (tableStatus == 'preparing') {
          return preparingBar();
        }

        if (tableStatus == 'pending') {
          return pendingBar();
        }

        if (tableStatus == 'paid') {
          return SizedBox.shrink();
        }

        if (quantities.isNotEmpty) {
          return viewOrderBar();
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget pendingBar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        child: SafeArea(
          top: false,
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.white, size: 26),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Order Placed",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),

              if (_lastOrderItems.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceiptScreen(
                          items: _lastOrderItems,
                          tableNo: widget.tableNo,
                          time: _lastOrderTime!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "View Bill",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget preparingBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        child: SafeArea(
          top: false,
          child: Row(
            children: [
              const Icon(Icons.restaurant, color: Colors.white, size: 26),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Preparing your order",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),

              if (_lastOrderItems.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceiptScreen(
                          items: _lastOrderItems,
                          tableNo: widget.tableNo,
                          time: _lastOrderTime!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "View Bill",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget readyBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 87, 165, 91),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),

        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 26),
              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  "Order is ready",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const Spacer(),

              if (_lastOrderItems.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceiptScreen(
                          items: _lastOrderItems,
                          tableNo: widget.tableNo,
                          time: _lastOrderTime!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("View Bill"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget viewOrderBar() {
    final totalItems = getTotalItems();
    final totalPrice = getTotalPrice();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 87, 165, 91),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),

        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$totalItems item${totalItems > 1 ? 's' : ''}",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),

                  Text(
                    "₹ ${totalPrice.toStringAsFixed(0)}",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () async {
                  final cartItems = buildCartItems();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderSummaryScreen(
                        tableNo: widget.tableNo,
                        cartItems: cartItems,
                      ),
                    ),
                  );

                  if (result == true) {
                    setState(() {
                      _lastOrderItems = cartItems;
                      quantities.clear();
                      // showReadyBar = true;
                    });
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2E7D32),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                child: Text(
                  "View Order",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<CartItem> buildCartItems() {
    List<CartItem> cart = [];

    for (var item in menuItems) {
      final qty = quantities[item.id] ?? 0;

      if (qty > 0) {
        cart.add(CartItem(item: item, quantity: qty));
      }
    }
    return cart;
  }
}
