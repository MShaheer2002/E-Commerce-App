import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/analytics_model.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';
import 'package:e_commerce_app/presentation/models/sale_entry_model.dart';
import 'package:flutter/material.dart';

class GlobalAnalyticsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GlobalAnalyticsModel? _analytics;
  GlobalAnalyticsModel? get analytics => _analytics;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _todaySales = 0;

  int get todaySales => _todaySales;

  String _filter = 'Month';
  String get filter => _filter;

  // Filtered data based on time period
  List<SaleEntry> _filteredSales = [];
  List<OrderModel> _filteredOrders = [];

  List<SaleEntry> get filteredSales => _filteredSales;
  List<OrderModel> get filteredOrders => _filteredOrders;

  // Computed metrics from filtered data
  double _filteredRevenue = 0;
  int _filteredItemsSold = 0;
  int _ordersCompleted = 0;
  int _ordersPending = 0;
  int _ordersCancelled = 0;

  double get filteredRevenue => _filteredRevenue;
  int get filteredItemsSold => _filteredItemsSold;
  int get ordersCompleted => _ordersCompleted;
  int get ordersPending => _ordersPending;
  int get ordersCancelled => _ordersCancelled;

  void setFilter(String newFilter) {
    _filter = newFilter;
    _applyFilter();
    notifyListeners();
  }

  /// 🔹 Fetch analytics from Firestore (doesn't regenerate)
  Future<void> fetchGlobalAnalytics() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('global_analytics')
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _analytics = GlobalAnalyticsModel.fromMap(snapshot.docs.first.data());
        _applyFilter();
        log("✅ Loaded latest analytics snapshot");
      } else {
        log("⚠️ No analytics data found. Please generate analytics first.");
      }
    } catch (e, s) {
      log("❌ Error fetching analytics: $e", stackTrace: s);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Generate new analytics snapshot
  Future<void> generateAnalytics() async {
    try {
      _isLoading = true;
      notifyListeners();

      log("[Global Analytics] Generating new analytics snapshot...");

      // Fetch orders
      final ordersSnap = await _firestore.collection('orders').get();
      final orders =
          ordersSnap.docs.map((d) => OrderModel.fromMap(d.data())).toList();

      // Fetch sales logs
      final salesSnap = await _firestore.collection('sales_logs').get();
      final sales =
          salesSnap.docs.map((d) => SaleEntry.fromMap(d.data())).toList();

      // Compute totals
      double totalRevenue = 0;
      int totalOrders = orders.length;
      int totalItemsSold = 0;
      int totalStock = 0;

      for (var order in orders) {
        totalRevenue += order.totalAmount;
        for (var item in order.cartItems) {
          totalItemsSold += item.quantity;
        }
      }

      // Get total stock from all products
      final productSnap = await _firestore.collection('products').get();
      for (var doc in productSnap.docs) {
        totalStock += (doc.data()['stock'] ?? 0) as int;
      }

      final analytics = GlobalAnalyticsModel(
        generatedAt: Timestamp.now(),
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        totalItemsSold: totalItemsSold,
        totalStock: totalStock,
        salesLogs: sales,
        orders: orders,
      );

      // Save to Firestore
      await _firestore.collection('global_analytics').add(analytics.toMap());

      _analytics = analytics;
      _applyFilter();

      log("✅ Analytics Generated: Revenue: \$$totalRevenue | Orders: $totalOrders | Items: $totalItemsSold | Stock: $totalStock");
    } catch (e, s) {
      log("❌ Error generating analytics: $e", stackTrace: s);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Apply time-based filter
  void _applyFilter() {
    if (_analytics == null) {
      _filteredSales = [];
      _filteredOrders = [];
      _filteredRevenue = 0;
      _filteredItemsSold = 0;
      _ordersCompleted = 0;
      _ordersPending = 0;
      _ordersCancelled = 0;
      return;
    }

    if (_filter == 'All Time') {
      _filteredSales = _analytics!.salesLogs;
      _filteredOrders = _analytics!.orders;
    } else {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      switch (_filter) {
        case 'Month':
          startDate = DateTime(now.year, now.month, 1, 0, 0, 0);
          endDate = DateTime(now.year, now.month + 1, 1, 0, 0, 0)
              .subtract(const Duration(seconds: 1));
          break;
        case 'Year':
          startDate = DateTime(now.year, 1, 1, 0, 0, 0);
          endDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        default: // Week
          startDate = DateTime(now.year, now.month, now.day, 0, 0, 0)
              .subtract(const Duration(days: 6));
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      }

      _filteredSales = _analytics!.salesLogs.where((sale) {
        final date = sale.boughtAt.toDate();
        return !date.isBefore(startDate) && !date.isAfter(endDate);
      }).toList();

      _filteredOrders = _analytics!.orders.where((order) {
        final date = order.orderDate.toDate();
        return !date.isBefore(startDate) && !date.isAfter(endDate);
      }).toList();
    }

    // Calculate metrics from filtered data
    _filteredRevenue = 0;
    _filteredItemsSold = 0;
    _ordersCompleted = 0;
    _ordersPending = 0;
    _ordersCancelled = 0;

    for (var order in _filteredOrders) {
      _filteredRevenue += order.totalAmount;
      for (var item in order.cartItems) {
        _filteredItemsSold += item.quantity;
      }

      switch (order.orderStatus) {
        case OrderStatus.delivered:
          _ordersCompleted++;
          break;
        case OrderStatus.cancelled:
          _ordersCancelled++;
          break;
        case OrderStatus.placed:
        case OrderStatus.shipped:
          _ordersPending++;
          break;
      }
    }

    log("[Global Analytics] Filter=$_filter | Revenue: \$$_filteredRevenue | Orders: ${_filteredOrders.length} | Items: $_filteredItemsSold");
  }

  Future<void> getTodaysOrdersCount() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('orders')
          .where('orderDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('orderDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      _todaySales = querySnapshot.docs.length;

      log("📅 Today's Orders: $count");
    } catch (e, s) {
      log("❌ Error getting today's orders: $e", stackTrace: s);
    }
  }
}
