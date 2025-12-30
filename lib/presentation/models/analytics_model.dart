import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ProductPlug/presentation/models/order_model.dart';
import 'package:ProductPlug/presentation/models/sale_entry_model.dart';

class GlobalAnalyticsModel {
  /// Timestamp of the analytics snapshot (daily/weekly/monthly)
  final Timestamp generatedAt;

  /// Total revenue (sum of all completed orders)
  final double totalRevenue;

  /// Total number of orders placed
  final int totalOrders;

  /// Total number of items sold across all products
  final int totalItemsSold;

  /// Total available stock across all products
  final int totalStock;

  /// All individual sale logs (for trend analysis)
  final List<SaleEntry> salesLogs;

  /// List of all completed orders for detailed view
  final List<OrderModel> orders;

  GlobalAnalyticsModel({
    required this.generatedAt,
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalItemsSold,
    required this.totalStock,
    required this.salesLogs,
    required this.orders,
  });

  /// ✅ Convert model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'generatedAt': generatedAt,
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'totalItemsSold': totalItemsSold,
      'totalStock': totalStock,
      'salesLogs': salesLogs.map((s) => s.toMap()).toList(),
      'orders': orders.map((o) => o.toMap()).toList(),
    };
  }

  /// ✅ Construct from Firestore map
  factory GlobalAnalyticsModel.fromMap(Map<String, dynamic> map) {
    return GlobalAnalyticsModel(
      generatedAt: map['generatedAt'] ?? Timestamp.now(),
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      totalOrders: (map['totalOrders'] ?? 0).toInt(),
      totalItemsSold: (map['totalItemsSold'] ?? 0).toInt(),
      totalStock: (map['totalStock'] ?? 0).toInt(),
      salesLogs: (map['salesLogs'] as List<dynamic>? ?? [])
          .map((e) => SaleEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      orders: (map['orders'] as List<dynamic>? ?? [])
          .map((e) => OrderModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

}
