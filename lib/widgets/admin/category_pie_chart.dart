import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_order_mgmt_app/enums/menu_category.dart';
import 'package:kitchen_order_mgmt_app/services/firestore_service.dart';

class CategoryPieChart extends StatelessWidget {
  final DateTime? selectedDate;

  const CategoryPieChart({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<MenuCategory, int>>(
      stream: FirestoreService().getFoodCategoryDistribution(selectedDate),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        if (data.isEmpty) {
          return const Center(child: Text("No data"));
        }

        final Map<MenuCategory, Color> categoryColors = {
          MenuCategory.starters: Color(0xFF2563EB),
          MenuCategory.curries: Color(0xFF3B82F6),
          MenuCategory.breads: Color(0xFF60A5FA),
          MenuCategory.biryani: Color(0xFF93C5FD),
          MenuCategory.beverages: Color(0xFFBFDBFE),
          MenuCategory.deserts: Color(0xFF1D4ED8),
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Food Category Distribution",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: PieChart(
                PieChartData(
                  sections: data.entries
                      .map((entry) {
                        if (entry.value == 0) {
                          return null;
                        }

                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: entry.key.name, // enum → string
                          color: categoryColors[entry.key],
                          radius: 90,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      })
                      .whereType<PieChartSectionData>()
                      .toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
