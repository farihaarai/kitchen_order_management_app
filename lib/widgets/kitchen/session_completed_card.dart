import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';

class SessionCompletedCard extends StatelessWidget {
  final String sessionId; // Unique session identifier
  final List<QueryDocumentSnapshot> docs; // All READY orders of this session

  const SessionCompletedCard({
    super.key,
    required this.sessionId,
    required this.docs,
  });

  @override
  Widget build(BuildContext context) {
    // All orders in this session belong to the same table
    final firstData = docs.first.data() as Map<String, dynamic>;
    final tableNo = firstData['tableNumber'];

    // ------------------------------------------------------------
    // Combine items from multiple orders
    // ------------------------------------------------------------
    Map<String, Map<String, dynamic>> combined = {};
    double total = 0;

    // Loop through each order
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final isRedo = data['isRedo'] ?? false;
      if (isRedo) continue; // skip redo orders

      final items = (data['items'] as List?) ?? [];

      for (var item in items) {
        final name = item['name'];
        final price = (item['price'] as num).toDouble();
        final qty = (item['quantity'] as num).toInt();

        if (combined.containsKey(name)) {
          combined[name]!['quantity'] += qty;
        } else {
          combined[name] = {'price': price, 'quantity': qty};
        }

        total += price * qty;
      }
    }

    final entries = combined.entries.toList();
    final visibleItems = entries.take(5).toList();
    final remaining = entries.length - visibleItems.length;

    // ------------------------------------------------------------
    // UI Card
    // ------------------------------------------------------------
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table number header
            Text(
              "Table $tableNo",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Combined item list
            ...visibleItems.map((entry) {
              final name = entry.key;
              final qty = entry.value['quantity'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("$name x$qty"),
              );
            }),

            if (remaining > 0)
              GestureDetector(
                onTap: () {
                  _showFullSession(context, tableNo, combined);
                },
                child: Text(
                  "+$remaining more",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const Spacer(),

            // Session total amount
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Total: ₹ ${total.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // ------------------------------------------------------------
            // MARK PAID BUTTON AND REDO BUTTON
            // ------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      "REDO",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: () {
                      _showRedoDialog(context, docs);
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.payments),
                    label: const Text(
                      "MARK PAID",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: () {
                      FirestoreService().markSessionPaid(sessionId);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFullSession(
    BuildContext context,
    int tableNo,
    Map<String, Map<String, dynamic>> combined,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// HEADER
                Row(
                  children: [
                    const Icon(
                      Icons.table_restaurant,
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),
                    const SizedBox(width: 8),

                    Text(
                      "Table $tableNo",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const Divider(),

                const SizedBox(height: 8),

                /// ITEM LIST
                ...combined.entries.map((entry) {
                  final name = entry.key;
                  final qty = entry.value['quantity'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "x$qty",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                /// FOOTER BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "CLOSE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRedoDialog(BuildContext context, List<QueryDocumentSnapshot> docs) {
    Map<String, Map<String, dynamic>> combined = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final isRedo = data['isRedo'] ?? false;
      if (isRedo) continue; // skip previous redo orders

      final items = (data['items'] as List?) ?? [];

      for (var item in items) {
        final name = item['name'];
        final qty = (item['quantity'] as num).toInt();
        final price = (item['price'] as num).toDouble();

        if (combined.containsKey(name)) {
          combined[name]!['quantity'] += qty;
        } else {
          combined[name] = {'name': name, 'price': price, 'quantity': qty};
        }
      }
    }

    final allItems = combined.values.toList();

    List<int> selected = List.generate(allItems.length, (_) => 0);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Select items to redo"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: List.generate(allItems.length, (i) {
                    final item = allItems[i];

                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['name'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (selected[i] > 0) {
                              setState(() {
                                selected[i]--;
                              });
                            }
                          },
                        ),

                        Text("${selected[i]}"),

                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (selected[i] < item['quantity']) {
                              setState(() {
                                selected[i]++;
                              });
                            }
                          },
                        ),

                        // Text("/ ${item['quantity']}"),
                      ],
                    );
                  }),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> redoItems = [];

                for (int i = 0; i < allItems.length; i++) {
                  if (selected[i] > 0) {
                    redoItems.add({
                      'name': allItems[i]['name'],
                      'price': allItems[i]['price'],
                      'quantity': selected[i],
                    });
                  }
                }

                if (redoItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Select at least one item")),
                  );
                  return;
                }

                final data = docs.first.data() as Map<String, dynamic>;

                await FirestoreService().createRedoOrder(
                  originalData: data,
                  redoItems: redoItems,
                );

                Navigator.pop(context);
              },
              child: Text("REDO"),
            ),
          ],
        );
      },
    );
  }
}
