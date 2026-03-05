import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/customer_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final int tableNo;
  const WelcomeScreen({super.key, required this.tableNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 63, 134, 66),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.food_bank_outlined, color: Colors.white, size: 70),

            const SizedBox(height: 20),

            const Text(
              "ROYAL SPICE",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerScreen(tableNo: tableNo),
                  ),
                );
              },
              child: Text(
                "View Menu",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
