import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';

class OrderCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final bool isCompleted;
  const OrderCard({super.key, this.isCompleted = false, required this.doc});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    final data = widget.doc.data() as Map<String, dynamic>;
    final isRedo = data['isRedo'] ?? false;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 1, end: 4).animate(_controller);

    if (isRedo) {
      _controller.repeat(reverse: true); // blinking border
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final docId = widget.doc.id;
    final status = data['status'];
    final tableNumber = (data['tableNumber'] as num?)?.toInt() ?? 0;

    final items = (data['items'] as List?) ?? [];
    final visibleItems = items.take(5).toList();
    final remaining = items.length - visibleItems.length;

    final Timestamp? ts = data['time'] is Timestamp
        ? data['time'] as Timestamp
        : null;
    final DateTime? time = ts?.toDate();
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final data = widget.doc.data() as Map<String, dynamic>;
        final isRedo = data['isRedo'] ?? false;

        return Container(
          decoration: BoxDecoration(
            border: isRedo
                ? Border.all(color: Colors.red, width: _animation.value)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Table $tableNumber",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  if ((data['isRedo'] ?? false) == true)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.refresh, color: Colors.white, size: 12),
                          SizedBox(width: 3),
                          Text(
                            "REDO",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    time != null
                        ? "${time.hour}:${time.minute.toString().padLeft(2, '0')}"
                        : "--:--",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Items in order
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...visibleItems.map((item) {
                    final qty = (item['quantity'] as num?)?.toInt() ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "${item['name']} x$qty",
                        style: const TextStyle(fontSize: 15),
                      ),
                    );
                  }),

                  if (remaining > 0)
                    GestureDetector(
                      onTap: () => _showFullOrder(context, tableNumber, items),
                      child: Text(
                        "+$remaining more",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const Spacer(),

              // const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: status == 'pending'
                      ? Colors.red.shade100
                      : status == 'preparing'
                      ? Colors.orange.shade100
                      : status == 'ready'
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status == 'pending'
                        ? Colors.red
                        : status == 'preparing'
                        ? Colors.orange
                        : status == "ready"
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
              ),

              SizedBox(height: 10),

              // ACTIVE TAB BUTTONS
              if (!widget.isCompleted && status == 'pending')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      FirestoreService().updateOrderStatus(docId, 'preparing');
                    },
                    child: const Text(
                      "START PREPARING",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else if (!widget.isCompleted && status == 'preparing')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      FirestoreService().updateOrderStatus(docId, 'ready');
                    },
                    child: const Text(
                      "MARK READY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              // COMPLETED TAB BUTTON
              else if (widget.isCompleted && status == 'ready')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      FirestoreService().updateOrderStatus(docId, 'paid');
                    },
                    child: const Text(
                      "MARK PAID",
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
      ),
    );
  }

  void _showFullOrder(BuildContext context, int tableNumber, List items) {
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
                      size: 26,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      "Table $tableNumber",
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: items.map((item) {
                        final qty = (item['quantity'] as num?)?.toInt() ?? 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'],
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// CLOSE BUTTON
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
}
