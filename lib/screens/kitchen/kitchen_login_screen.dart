import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/kitchen_screen.dart';

class KitchenLoginScreen extends StatefulWidget {
  const KitchenLoginScreen({super.key});

  @override
  State<KitchenLoginScreen> createState() => _KitchenLoginScreenState();
}

class _KitchenLoginScreenState extends State<KitchenLoginScreen> {
  final pinController = TextEditingController();

  final String kitchenPin = "****";

  void checkPin() {
    if (pinController.text == kitchenPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KitchenScreen()),
      );
    } else {
      pinController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid Kitchen PIN")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kitchen Access"),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_person_rounded,
                size: 70,
                color: Color(0xFF2E7D32),
              ),

              SizedBox(height: 10),

              Text(
                "Enter Kitchen PIN",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter access PIN",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: checkPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  "ENTER",
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
