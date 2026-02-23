import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchen_order_mgmt_app/app_router.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_bloc.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/customer_screen.dart';
import 'package:kitchen_order_mgmt_app/screens/customer/table_entry_screen.dart';
import 'package:kitchen_order_mgmt_app/screens/kitchen/kitchen_screen.dart';
import 'package:kitchen_order_mgmt_app/screens/start_screen.dart';

class KitchenOrderMgmt extends StatelessWidget {
  const KitchenOrderMgmt({super.key});
  // caricature
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderBloc(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
