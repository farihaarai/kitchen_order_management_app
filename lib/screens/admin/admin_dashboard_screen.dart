import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/analytics_service.dart';
import 'package:kitchen_order_mgmt_app/services/kitchen_service.dart';
import 'package:kitchen_order_mgmt_app/widgets/admin/category_pie_chart.dart';
import 'package:kitchen_order_mgmt_app/widgets/admin/daily_sales_chart.dart';
import 'package:kitchen_order_mgmt_app/widgets/admin/metric_card.dart';
import 'package:kitchen_order_mgmt_app/widgets/admin/orders_chart.dart';
import 'package:kitchen_order_mgmt_app/widgets/admin/sales_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  DateTime? selectedDate;

  void pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f7fa),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 20,
        title: Row(
          children: [
            Icon(Icons.analytics, color: Colors.black),
            SizedBox(width: 10),
            Text(
              "Restaurant Analytics",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),

      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final width = constraints.maxWidth;

          final isMobile = width < 600;
          final isTablet = width >= 600 && width < 1000;
          final isDesktop = width >= 1000;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 24,
              vertical: 20,
            ),
            child: _buildDashboard(isMobile, isTablet, isDesktop),
          );
        },
      ),
    );
  }

  Widget _buildDashboard(bool isMobile, bool isTablet, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),

              Text(
                selectedDate == null
                    ? "All Time"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(width: 10),

              GestureDetector(
                onTap: pickDate,
                child: const Icon(Icons.edit_calendar, size: 18),
              ),

              if (selectedDate != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = null;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.close, size: 18),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Metrics
        GridView.count(
          crossAxisCount: isMobile
              ? 2
              : isTablet
              ? 3
              : 6,
          shrinkWrap: true,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isMobile ? 2.5 : 3,
          children: [
            StreamBuilder<double>(
              stream: AnalyticsService().getSales(selectedDate),
              builder: (context, snapshot) {
                final sales = snapshot.data ?? 0;

                return MetricCard(
                  title: "Sales Today",
                  value: "₹${sales.toStringAsFixed(0)}",
                  icon: Icons.payments,
                  color: Colors.green,
                );
              },
            ),

            StreamBuilder<int>(
              stream: AnalyticsService().getOrders(selectedDate),
              builder: (context, snapshot) {
                final orders = snapshot.data ?? 0;

                final now = DateTime.now();

                final isToday =
                    selectedDate != null &&
                    selectedDate!.year == now.year &&
                    selectedDate!.month == now.month &&
                    selectedDate!.day == now.day;

                return MetricCard(
                  title: selectedDate == null
                      ? "Total Orders"
                      : isToday
                      ? "Orders Today"
                      : "Orders on ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  value: orders.toString(),
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                );
              },
            ),

            StreamBuilder<int>(
              stream: AnalyticsService().getActiveTables(),
              builder: (context, snapshot) {
                final tables = snapshot.data ?? 0;

                return MetricCard(
                  title: "Active Tables",
                  value: tables.toString(),
                  icon: Icons.table_restaurant,
                  color: Colors.purple,
                );
              },
            ),
            StreamBuilder<int>(
              stream: KitchenService().getRedoOrdersCount(selectedDate),
              builder: (context, snapshot) {
                final redo = snapshot.data ?? 0;

                return MetricCard(
                  title: "Redo Orders",
                  value: redo.toString(),
                  icon: Icons.refresh,
                  color: Colors.red,
                );
              },
            ),

            StreamBuilder<Map<String, dynamic>>(
              stream: AnalyticsService().getPeakOrderHour(selectedDate),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final data = snapshot.data!;
                final hour = data["hour"];

                return MetricCard(
                  title: "Peak Hours",
                  value: "$hour:00 ",
                  icon: Icons.schedule,
                  color: Colors.orange,
                );
              },
            ),

            StreamBuilder<double>(
              stream: AnalyticsService().getAverageOrderValue(selectedDate),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final avg = snapshot.data ?? 0;

                return MetricCard(
                  title: "Avg Order Value",
                  value: "₹${avg.toStringAsFixed(0)}",
                  icon: Icons.trending_up,
                  color: Colors.teal,
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 32),

        /// SALES CHART
        const Text(
          "Sales Today",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10),
            ],
          ),

          child: isMobile
              ? Column(
                  children: [
                    SizedBox(
                      height: 260,
                      child: SalesChart(selectedDate: selectedDate),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 260,
                      child: OrdersChart(selectedDate: selectedDate),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 260,
                        child: SalesChart(selectedDate: selectedDate),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 260,
                        child: OrdersChart(selectedDate: selectedDate),
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 32),

        const Text(
          "Trends & Distribution",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        isMobile
            ? Column(
                children: [
                  Container(
                    height: 260,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const DailySalesChart(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CategoryPieChart(selectedDate: selectedDate),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 260,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const DailySalesChart(),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Container(
                      height: 260,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CategoryPieChart(selectedDate: selectedDate),
                    ),
                  ),
                ],
              ),

        const SizedBox(height: 32),

        // Item insights
        isMobile
            ? Column(
                children: [
                  _topSellingSection(),
                  const SizedBox(height: 16),
                  _redoSection(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _topSellingSection()),
                  const SizedBox(width: 16),
                  Expanded(child: _redoSection()),
                ],
              ),
      ],
    );
  }

  Widget _topSellingSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top Selling Items",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: AnalyticsService().getTopSellingItems(selectedDate),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final items = snapshot.data!;

              return Column(
                children: items.map((item) {
                  return _buildTopItem(item["name"], "${item["qty"]} orders");
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _redoSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Most Redo Items",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: AnalyticsService().getMostRedoItems(selectedDate),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final items = snapshot.data!;

              return Column(
                children: items.map((item) {
                  return _buildTopItem(item["name"], "${item["qty"]} redo");
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopItem(String name, String orders) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant_menu, size: 20),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Text(
            orders,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
