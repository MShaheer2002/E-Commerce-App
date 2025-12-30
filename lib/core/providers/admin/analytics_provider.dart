import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ProductPlug/presentation/models/sale_entry_model.dart';
import 'package:ProductPlug/presentation/models/product_analytics_model.dart';
import 'package:flutter/material.dart';

class AnalyticsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProductAnalytics? _analytics;
  ProductAnalytics? get analytics => _analytics;

  String _filter = 'Week';
  String get filter => _filter;

  List<SaleEntry> _filteredSales = [];
  List<SaleEntry> get filteredSales => _filteredSales;

  void setFilter(String newFilter) {
    _filter = newFilter;
    _applyFilter();
    notifyListeners();
  }

  Future<void> getProductAnalytics(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc =
          await _db.collection("product_analytics").doc(productId).get();

      if (!doc.exists) {
        log("[Analytics] No analytics data found for product: $productId");
        _analytics = null;
        _filteredSales = [];
        return;
      }

      _analytics = ProductAnalytics.fromMap(doc.data()!);
      _applyFilter();
    } catch (e) {
      log("[Analytics] Error fetching product analytics: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Calendar-based filter logic (Week, Month, Year, All Time)
  void _applyFilter() {
    if (_analytics == null || _analytics!.sales.isEmpty) {
      _filteredSales = [];
      return;
    }

    if (_filter == 'All Time') {
      // ✅ Show all sales
      _filteredSales = List.from(_analytics!.sales)
        ..sort((a, b) => a.boughtAt.toDate().compareTo(b.boughtAt.toDate()));
      log("[Analytics] Filter=All Time | Showing ${_filteredSales.length} sales");
      return;
    }

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_filter) {
      case 'Month':
        // ✅ Current month only (from 1st to end of month)
        startDate = DateTime(now.year, now.month, 1, 0, 0, 0);
        endDate = DateTime(now.year, now.month + 1, 1, 0, 0, 0)
            .subtract(const Duration(seconds: 1));
        break;

      case 'Year':
        // ✅ Current year only (from Jan 1 to Dec 31)
        startDate = DateTime(now.year, 1, 1, 0, 0, 0);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;

      default: // Week
        // ✅ Last 7 days including today (6 days back + today)
        startDate = DateTime(now.year, now.month, now.day, 0, 0, 0)
            .subtract(const Duration(days: 6));
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    _filteredSales = _analytics!.sales.where((s) {
      final date = s.boughtAt.toDate();
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).toList()
      ..sort((a, b) => a.boughtAt.toDate().compareTo(b.boughtAt.toDate()));

    log("[Analytics] Filter=$_filter | Showing ${_filteredSales.length} sales | Range: ${startDate.toString().split(' ')[0]} → ${endDate.toString().split(' ')[0]}");
  }
}