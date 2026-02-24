import 'package:go_router/go_router.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/customer_screen.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/kitchen_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <GoRoute>[
    // GoRoute(
    //   path: '/',
    //   builder: (context, state) {
    //     return const KitchenScreen();
    //   },
    // ),
    GoRoute(
      path: '/kitchen',
      builder: (context, state) {
        return const KitchenScreen();
      },
    ),

    GoRoute(
      path: '/table/:tableNo',
      builder: (context, state) {
        // Extract parameter from URL
        final tableNoString = state.pathParameters['tableNo'];

        // Convert to int safely
        final tableNo = int.tryParse(tableNoString ?? '');

        // If invalid, go to start screen
        // if (tableNo == null) {
        //   return const StartScreen();
        // }

        return CustomerScreen(tableNo: tableNo!);
      },
    ),
  ],
);
