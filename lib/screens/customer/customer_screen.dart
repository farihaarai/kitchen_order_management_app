import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/core/data/menu_data.dart';
import 'package:kitchen_order_mgmt_app/enums/food_type.dart';
import 'package:kitchen_order_mgmt_app/enums/menu_category.dart';
import 'package:kitchen_order_mgmt_app/models/cart_item.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/order_progress_screen.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/order_summary_screen.dart';
import 'package:kitchen_order_mgmt_app/services/cart_service.dart';
import 'package:kitchen_order_mgmt_app/services/order_service.dart';
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
  // Map<String, int> quantities = {};
  // ignore: unused_field
  List<CartItem> _lastOrderItems = [];
  // ignore: unused_field
  DateTime? _lastOrderTime;
  MenuCategory _selectedCategory = MenuCategory.starters;
  FoodType? _selectedFoodType;
  final _scrollController = ScrollController();
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.offset > 60 && !_collapsed) {
        setState(() {
          _collapsed = true;
        });
      } else if (_scrollController.offset <= 60 && _collapsed) {
        setState(() {
          _collapsed = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32), // deep food green
        foregroundColor: Colors.white,
        elevation: 3,
        centerTitle: false,
        titleSpacing: 12,
        title: Row(
          children: [
            const Icon(Icons.food_bank_outlined, size: 40),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ROYAL SPICE",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Table ${widget.tableNo}",
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(height: 8),
                CategorySelector(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                      _selectedFoodType =
                          null; // reset filter when category change
                    });
                    _scrollController.jumpTo(0);
                  },
                ),

                Divider(),

                VegFilter(
                  selectedType: _selectedFoodType,
                  onchanged: (type) {
                    setState(() {
                      _selectedFoodType = type;
                    });
                    _scrollController.jumpTo(0);
                  },
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: OrderService().getOrdersForTable(widget.tableNo),
                  builder: (context, orderSnapshot) {
                    int activeOrderCount = 0;
                    if (orderSnapshot.hasData) {
                      final docs = orderSnapshot.data!.docs;

                      activeOrderCount = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final status = data['status'];
                        final isRedo = data['isRedo'] ?? false;

                        return status != 'paid' && isRedo == false;
                      }).length;
                    }

                    bool limitReached = activeOrderCount >= 4;

                    return StreamBuilder<QuerySnapshot>(
                      stream: CartService().getCartStream(widget.tableNo),
                      builder: (context, snapshot) {
                        // convert firestore cart to map
                        Map<String, int> quantities = {};

                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            quantities[doc['id']] = (doc['quantity'] as num)
                                .toInt();
                          }
                        }

                        final filteredItems = menuItems.where((item) {
                          final categoryMatch =
                              item.category == _selectedCategory;
                          final typeMatch = _selectedFoodType == null
                              ? true
                              : item.type == _selectedFoodType;
                          return categoryMatch && typeMatch;
                        }).toList();

                        return Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              int columns = 1;

                              if (constraints.maxWidth > 1000) {
                                columns = 3;
                              } else if (constraints.maxWidth > 600) {
                                columns = 2;
                              }

                              return GridView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.fromLTRB(8, 8, 8, 160),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: columns == 1
                                          ? 0.82
                                          : columns == 2
                                          ? 0.75
                                          : 0.72,
                                    ),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];

                                  return Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: MenuItemTile(
                                      item: item,
                                      quantity: quantities[item.id] ?? 0,
                                      onIncrease: () {
                                        if (limitReached) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Maximum 4 orders allowed",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        CartService()
                                            .addToCart(widget.tableNo, {
                                              'id': item.id,
                                              'name': item.name,
                                              'price': item.price,
                                            });
                                      },
                                      onDecrease: () {
                                        CartService().decreaseCartItem(
                                          widget.tableNo,
                                          item.id,
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          _buildFloatingOrderIndicator(),
        ],
      ),

      bottomNavigationBar: _buildStatusBar(),
    );
  }

  Widget _buildStatusBar() {
    return StreamBuilder<QuerySnapshot>(
      stream: CartService().getCartStream(widget.tableNo),
      builder: (context, cartSnapshot) {
        int totalItems = 0;
        double totalPrice = 0;

        Map<String, int> quantities = {};

        if (cartSnapshot.hasData) {
          for (var doc in cartSnapshot.data!.docs) {
            final qty = (doc['quantity'] as num).toInt();
            final price = (doc['price'] as num).toDouble();

            quantities[doc['id']] = qty;
            totalItems += qty;
            totalPrice += qty * price;
          }
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(position: slideAnimation, child: child);
          },
          child: totalItems > 0
              ? Container(
                  key: const ValueKey("cartVisible"),
                  child: viewOrderBar(quantities, totalItems, totalPrice),
                )
              : const SizedBox(key: ValueKey("cartHidden")),
        );
      },
    );
  }

  Widget _buildFloatingOrderIndicator() {
    return StreamBuilder<QuerySnapshot>(
      stream: OrderService().getOrdersForTable(widget.tableNo),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;

        final activeDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] != 'paid';
        }).toList();

        if (activeDocs.isEmpty) return SizedBox.shrink();

        String text;
        IconData icon;
        VoidCallback? onTap;

        if (activeDocs.length > 1) {
          text = "${activeDocs.length} Orders in progress";
          icon = Icons.list_alt;

          onTap = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderProgressScreen(tableNo: widget.tableNo),
              ),
            );
          };
        } else {
          final data = activeDocs.first.data() as Map<String, dynamic>;
          final status = data['status'];

          if (status == "pending") {
            text = "Order placed";
            icon = Icons.receipt_long;
          } else if (status == "preparing") {
            text = "Preparing your order";
            icon = Icons.restaurant;
          } else if (status == "ready") {
            text = "Order ready";
            icon = Icons.check_circle;
          } else {
            return const SizedBox.shrink();
          }

          onTap = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderProgressScreen(tableNo: widget.tableNo),
              ),
            );
          };
        }

        return Positioned(
          bottom: 30,
          right: 16,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget viewOrderBar(
    Map<String, int> quantities,
    int totalItems,
    double totalPrice,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 87, 165, 91),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Text(
                "$totalItems item${totalItems > 1 ? 's' : ''}",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              SizedBox(width: 10),
              Text(
                "₹ ${totalPrice.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  // Build CartItems from Firestore data
                  List<CartItem> cartItems = [];

                  quantities.forEach((id, qty) {
                    final menuItem = menuItems.firstWhere((m) => m.id == id);
                    cartItems.add(CartItem(item: menuItem, quantity: qty));
                  });

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
                    _lastOrderItems = cartItems;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  minimumSize: const Size(0, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "View",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
