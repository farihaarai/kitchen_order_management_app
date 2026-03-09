import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/session_receipt_screen.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';

class OrderProgressScreen extends StatelessWidget {
  final int tableNo;

  const OrderProgressScreen({super.key, required this.tableNo});

  Color _getColor(String status) {
    if (status == 'pending') return Colors.grey;
    if (status == 'preparing') return Colors.orange;
    if (status == 'ready') return Colors.green;
    return Colors.grey;
  }

  String _getText(String status) {
    return status.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Table $tableNo - Orders Progress"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: FirestoreService().getActiveSessionOrders(tableNo),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // -------- Active orders (status != paid) --------
          final activeDocs = snapshot.data!;

          if (activeDocs.isEmpty) {
            return const Center(child: Text("No active orders"));
          }

          // -------- Sort by orderNo --------
          activeDocs.sort((a, b) {
            final aNo = (a['orderNo'] ?? 0) as int;
            final bNo = (b['orderNo'] ?? 0) as int;
            return aNo.compareTo(bNo);
          });

          // -------- Session total --------

          return Column(
            children: [
              // -------- Timeline List --------
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: activeDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        activeDocs[index].data() as Map<String, dynamic>;
                    final status = data['status'];
                    final orderNo = data['orderNo'];
                    final items = (data['items'] as List?) ?? [];
                    final isRedo = data['isRedo'] ?? false;

                    // -------- Order total --------
                    double orderTotal = 0;
                    for (var item in items) {
                      orderTotal +=
                          (item['price'] as num).toDouble() *
                          (item['quantity'] as num).toInt();
                    }

                    final isLast = index == activeDocs.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isRedo) const SizedBox(width: 25),
                        // Timeline dot + line
                        Column(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 80,
                                color: Colors.grey.shade300,
                              ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        // -------- Order Card --------
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isRedo
                                  ? Colors.red.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          isRedo ? "↳ REDO" : "Order #$orderNo",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        if (isRedo) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              "REDO",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getColor(
                                          status,
                                        ).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getText(status),
                                        style: TextStyle(
                                          color: _getColor(status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Items
                                ...items.map((item) {
                                  final qty = (item['quantity'] as num).toInt();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      "${item['name']} x$qty",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 6),

                                // Order total
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "₹ ${orderTotal.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // -------- Session Total Bar --------
              StreamBuilder<double>(
                stream: FirestoreService().getSessionTotal(tableNo),
                builder: (context, totalSnapshot) {
                  final total = totalSnapshot.data ?? 0;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Session Total: ₹ ${total.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SessionReceiptScreen(tableNo: tableNo),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("View Total Bill"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
