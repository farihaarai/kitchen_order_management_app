import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/services/analytics_service.dart';

class OrdersChart extends StatelessWidget {
  final DateTime? selectedDate;
  const OrdersChart({super.key, this.selectedDate});

  double calculateInterval(double maxValue) {
    const int labelCount = 6;

    double interval = maxValue / (labelCount - 1);

    if (interval <= 10) {
      interval = interval.ceilToDouble();
    } else if (interval <= 100) {
      interval = (interval / 10).ceil() * 10;
    } else if (interval <= 1000) {
      interval = (interval / 100).ceil() * 100;
    } else if (interval <= 5000) {
      interval = (interval / 500).ceil() * 500;
    } else {
      interval = (interval / 1000).ceil() * 1000;
    }

    return interval;
  }

  String formatHour(double value) {
    int hour = value.toInt();

    final period = hour >= 12 ? "PM" : "AM";
    int formattedHour = hour % 12;
    if (formattedHour == 0) formattedHour = 12;

    return "$formattedHour $period";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, int>>(
      stream: AnalyticsService().getHourlyOrders(selectedDate),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Text("No orders yet"));
        }

        final data = snapshot.data!;

        final sortedEntries = data.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        final spots = sortedEntries
            .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
            .toList();

        if (spots.isEmpty) {
          spots.add(const FlSpot(0, 0));
        }

        double maxValue = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        if (maxValue == 0) {
          maxValue = 5;
        }

        double interval = calculateInterval(maxValue);
        double maxY = interval * 5;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Orders by Hour",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8, bottom: 8),
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 23,
                    minY: 0,
                    maxY: maxY,

                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.15),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.15),
                          strokeWidth: 1,
                        );
                      },
                    ),

                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),

                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: interval,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          },
                        ),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 3,
                          getTitlesWidget: (value, meta) {
                            if (value % 3 != 0) {
                              return const SizedBox();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                formatHour(value),
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

                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            return LineTooltipItem(
                              "${formatHour(spot.x)} • ${spot.y.toInt()} orders",
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
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
            ),
          ],
        );
      },
    );
  }
}
