// import 'package:flutter/material.dart';
// import 'package:kitchen_order_mgmt_app/screens/customer/table_entry_screen.dart';
// import 'package:kitchen_order_mgmt_app/screens/kitchen/kitchen_screen.dart';

// class StartScreen extends StatelessWidget {
//   const StartScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Kitchen Order App")),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 60),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const TableEntryScreen()),
//                 );
//               },
//               child: const Text("Customer", style: TextStyle(fontSize: 18)),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 60),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const KitchenScreen()),
//                 );
//               },
//               child: const Text("Kitchen", style: TextStyle(fontSize: 18)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
