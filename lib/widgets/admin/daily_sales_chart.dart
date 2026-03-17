import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/analytics_service.dart';

class DailySalesChart extends StatelessWidget {
  const DailySalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, double>>(
      stream: AnalyticsService().getDailySalesTrend(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        final entries = data.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        final spots = entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "7 Day Sales Trend",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,

                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey.withOpacity(.15));
                    },
                  ),

                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "₹${value.toInt()}",
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            "",
                            "Mon",
                            "Tue",
                            "Wed",
                            "Thu",
                            "Fri",
                            "Sat",
                            "Sun",
                          ];

                          int dayIndex = value.toInt();

                          if (dayIndex < 1 || dayIndex > 7) {
                            return const SizedBox();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              days[dayIndex],
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),

                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
