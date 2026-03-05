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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Restaurant Branding
              const Icon(
                Icons.food_bank_outlined,
                size: 60,
                color: Color(0xFF2E7D32),
              ),

              const SizedBox(height: 10),

              const Text(
                "ROYAL SPICE",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const Text(
                "Kitchen Dashboard",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 30),

              /// Login Card
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_person_rounded,
                          size: 45,
                          color: Color(0xFF2E7D32),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "Kitchen Access",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: pinController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "••••",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: checkPin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("ENTER"),
                          ),
                        ),
                      ],
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
}
