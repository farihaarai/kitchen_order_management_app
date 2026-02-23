import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const KitchenOrderMgmt());
}
