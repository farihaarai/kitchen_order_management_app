import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitchen_order_mgmt_app/enums/menu_category.dart';

class AnalyticsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get Sales method
  Stream<double> getSales(DateTime? date) {
    return _db.collection('orders').snapshots().map((snapshot) {
      double total = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final isRedo = data['isRedo'] ?? false;
        if (isRedo) continue;

        final status = data['status'];
        if (status != 'paid') continue;

        final Timestamp ts = data['time'];
        final orderDate = ts.toDate();

        if (date != null) {
          if (orderDate.year != date.year ||
              orderDate.month != date.month ||
              orderDate.day != date.day) {
            continue;
          }
        }

        final items = (data['items'] as List?) ?? [];

        for (var item in items) {
          final price = (item['price'] as num).toDouble();
          final qty = (item['quantity'] as num).toInt();

          total += price * qty;
        }
      }

      return total;
    });
  }

  // get orders count method
  Stream<int> getOrders(DateTime? date) {
    return _db.collection('orders').snapshots().map((snapshot) {
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final isRedo = data['isRedo'] ?? false;
        if (isRedo) continue;

        final Timestamp ts = data['time'];
        final orderDate = ts.toDate();

        if (date != null) {
          if (orderDate.year != date.year ||
              orderDate.month != date.month ||
              orderDate.day != date.day) {
            continue;
          }
        }

        count++;
      }

      return count;
    });
  }

  // Active tables
  Stream<int> getActiveTables() {
    return _db.collection('orders').snapshots().map((snapshot) {
      final tables = <int>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'];
        final table = data['tableNumber'];

        if (status != 'paid') {
          tables.add(table);
        }
      }

      return tables.length;
    });
  }

  // Get top selling items
  Stream<List<Map<String, dynamic>>> getTopSellingItems(DateTime? date) {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'paid')
        .snapshots()
        .map((snapshot) {
          Map<String, int> itemCounts = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();

            final isRedo = data['isRedo'] ?? false;
            if (isRedo) continue;

            final Timestamp ts = data['time'];
            final orderDate = ts.toDate();

            if (date != null) {
              if (orderDate.year != date.year ||
                  orderDate.month != date.month ||
                  orderDate.day != date.day) {
                continue;
              }
            }

            final items = (data['items'] as List?) ?? [];

            for (var item in items) {
              final name = item['name'];
              final qty = (item['quantity'] as num).toInt();

              itemCounts[name] = (itemCounts[name] ?? 0) + qty;
            }
          }

          final sorted = itemCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return sorted
              .take(3)
              .map((e) => {"name": e.key, "qty": e.value})
              .toList();
        });
  }

  // method to get daily sales trends
  Stream<Map<int, double>> getDailySalesTrend() {
    return _db.collection('orders').snapshots().map((snapshot) {
      Map<int, double> dailySales = {};

      final now = DateTime.now();

      // initialize last 7 days
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        dailySales[day.weekday] = 0;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final isRedo = data['isRedo'] ?? false;
        if (isRedo) continue;

        final status = data['status'];
        if (status != 'paid') continue;

        final Timestamp ts = data['time'];
        final orderDate = ts.toDate();

        final nowMinus7 = now.subtract(const Duration(days: 6));

        if (orderDate.isBefore(nowMinus7)) continue;

        final items = (data['items'] as List?) ?? [];

        double total = 0;

        for (var item in items) {
          final price = (item['price'] as num).toDouble();
          final qty = (item['quantity'] as num).toInt();

          total += price * qty;
        }

        dailySales[orderDate.weekday] =
            (dailySales[orderDate.weekday] ?? 0) + total;
      }
      return dailySales;
    });
  }

  // method for category distribution pie chart
  Stream<Map<MenuCategory, int>> getFoodCategoryDistribution(DateTime? date) {
    return _db.collection('orders').snapshots().map((snapshot) {
      Map<MenuCategory, int> categoryCounts = {
        for (var c in MenuCategory.values) c: 0,
      };

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final isRedo = data['isRedo'] ?? false;
        if (isRedo) continue;

        final Timestamp ts = data['time'];
        final orderDate = ts.toDate();

        if (date != null) {
          if (orderDate.year != date.year ||
              orderDate.month != date.month ||
              orderDate.day != date.day) {
            continue;
          }
        }

        final items = data['items'] ?? [];

        for (var item in items) {
          final categoryString = item['category'];

          if (categoryString == null) continue;

          final category = MenuCategory.values.firstWhere(
            (c) => c.name == categoryString,
          );

          final qty = (item['quantity'] as num).toInt();

          categoryCounts[category] = (categoryCounts[category] ?? 0) + qty;
        }
      }

      return categoryCounts;
    });
  }

  // method to get average order value
  Stream<double> getAverageOrderValue(DateTime? date) {
    return _db.collection('orders').snapshots().map((snapshot) {
      double totalSales = 0;
      int totalOrders = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final isRedo = data['isRedo'] ?? false;
        if (isRedo) continue;

        final status = data['status'];
        if (status != 'paid') continue;

        final Timestamp ts = data['time'];
        final orderDate = ts.toDate();

        if (date != null) {
          if (orderDate.year != date.year ||
              orderDate.month != date.month ||
              orderDate.day != date.day) {
            continue;
          }
        }

        final items = (data['items'] as List?) ?? [];

        double orderTotal = 0;

        for (var item in items) {
          final price = (item['price'] as num).toDouble();
          final qty = (item['quantity'] as num).toInt();

          orderTotal += price * qty;
        }

        totalSales += orderTotal;
        totalOrders++;
      }

      if (totalOrders == 0) return 0;

      return totalSales / totalOrders;
    });
  }

  //  method to get kitchen load
  Stream<Map<String, int>> getKitchenLoad() {
    return _db.collection('orders').snapshots().map((snapshot) {
      int pending = 0;
      int preparing = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'];

        if (status == 'pending') pending++;
        if (status == 'preparing') preparing++;
      }

      return {
        "pending": pending,
        "preparing": preparing,
        "total": pending + preparing,
      };
    });
  }

  // Completed Sessions
  Stream<int> getCompletedSessions() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'paid')
        .snapshots()
        .map((snapshot) {
          final sessions = <String>{};

          for (var doc in snapshot.docs) {
            final data = doc.data();
            sessions.add(data['sessionId']);
          }

          return sessions.length;
        });
  }

  // get hourly sales
  Stream<Map<int, double>> getHourlySales(DateTime? date) {
    return _db.collection('orders').snapshots().map((snapshot) {
      Map<int, double> hourlySales = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final isRedo = data['isRedo'] ?? false;
        if (isRedo) continue;

        final status = data['status'];
        if (status != 'paid') continue;

        final Timestamp ts = data['time'];
        final orderDate = ts.toDate();

        if (date != null) {
          if (orderDate.year != date.year ||
              orderDate.month != date.month ||
              orderDate.day != date.day) {
            continue;
          }
        }
        final hour = orderDate.hour;

        final items = (data['items'] as List?) ?? [];

        double total = 0;

        for (var item in items) {
          final price = (item['price'] as num).toDouble();
          final qty = (item['quantity'] as num).toInt();

          total += price * qty;
        }

        hourlySales[hour] = (hourlySales[hour] ?? 0) + total;
      }

      print("Hourly sales: $hourlySales");
      return hourlySales;
    });
  }

  Stream<Map<int, int>> getHourlyOrders(DateTime? date) {
    return _db.collection('orders').snapshots().map((snapshot) {
      Map<int, int> hourlyOrders = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final isRedo = data['isRedo'] ?? false;
        if (isRedo) continue;

        final Timestamp ts = data['time'];
        final orderDate = ts.toDate();

        if (date != null) {
          if (orderDate.year != date.year ||
              orderDate.month != date.month ||
              orderDate.day != date.day) {
            continue;
          }
        }

        final hour = orderDate.hour;

        hourlyOrders[hour] = (hourlyOrders[hour] ?? 0) + 1;
      }

      return hourlyOrders;
    });
  }

  // method to get peak order hour
  Stream<Map<String, dynamic>> getPeakOrderHour(DateTime? date) {
    return _db.collection('orders').snapshots().map((snapshot) {
      Map<int, int> hourlyOrders = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final isRedo = data['isRedo'] ?? false;
        if (isRedo) continue;

        final Timestamp ts = data['time'];
        final orderDate = ts.toDate();

        if (date != null) {
          if (orderDate.year != date.year ||
              orderDate.month != date.month ||
              orderDate.day != date.day) {
            continue;
          }
        }

        final hour = orderDate.hour;

        hourlyOrders[hour] = (hourlyOrders[hour] ?? 0) + 1;
      }

      int peakHour = 0;
      int maxOrders = 0;

      hourlyOrders.forEach((hour, count) {
        if (count > maxOrders) {
          maxOrders = count;
          peakHour = hour;
        }
      });
      return {"hour": peakHour, "orders": maxOrders};
    });
  }

  // method to get most redo items
  Stream<List<Map<String, dynamic>>> getMostRedoItems(DateTime? date) {
    return _db
        .collection('orders')
        .where('isRedo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          Map<String, int> redoItems = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();

            final Timestamp ts = data['time'];
            final orderDate = ts.toDate();

            if (date != null) {
              if (orderDate.year != date.year ||
                  orderDate.month != date.month ||
                  orderDate.day != date.day) {
                continue;
              }
            }

            final items = data['items'] ?? [];

            for (var item in items) {
              final name = item['name'];
              final qty = (item['quantity'] as num).toInt();

              redoItems[name] = (redoItems[name] ?? 0) + qty;
            }
          }

          final sorted = redoItems.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return sorted
              .take(3)
              .map((e) => {"name": e.key, "qty": e.value})
              .toList();
        });
  }
}
