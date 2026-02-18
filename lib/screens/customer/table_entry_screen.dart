import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/customer_screen.dart';

class TableEntryScreen extends StatefulWidget {
  const TableEntryScreen({super.key});

  @override
  State<TableEntryScreen> createState() => _TableEntryScreenState();
}

class _TableEntryScreenState extends State<TableEntryScreen> {
  final TextEditingController tableController = TextEditingController();

  @override
  void dispose() {
    tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: tableController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Table No.",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                tableController.text.isEmpty
                    ? null
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerScreen(
                            tableNo: int.parse(tableController.text),
                          ),
                        ),
                      );
              },
              child: Text("Click to Order"),
            ),
          ],
        ),
      ),
    );
  }
}
