import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';

class OrderManagementProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  OrderStatus _currentStatus = OrderStatus.placed;
  OrderStatus get currentStatus => _currentStatus;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Track which tabs need reloading after status updates
  final Set<OrderStatus> _tabsNeedingReload = {};

  /// Check if a tab needs reloading
  bool shouldReloadTab(OrderStatus status) {
    return _tabsNeedingReload.contains(status);
  }

  /// Mark a tab as reloaded
  void markTabAsReloaded(OrderStatus status) {
    _tabsNeedingReload.remove(status);
  }

  /// 🔁 Switch Tab
  void setOrderStatus(OrderStatus status) {
    _currentStatus = status;
    fetchOrdersByStatus(status);
  }

  /// 📦 Fetch Orders by Status
  Future<void> fetchOrdersByStatus(OrderStatus status) async {
    _isLoading = true;
    _currentStatus = status;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('orderStatus', isEqualTo: status.name)
          .orderBy('orderDate', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromMap({
                ...doc.data(),
                'orderId': doc.id,
              }))
          .toList();
    } catch (e) {
      debugPrint("❌ Error fetching orders: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔄 Update Order Status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'orderStatus': newStatus.name,
      });

      // Mark both the current tab and the new status tab for reload
      _tabsNeedingReload.add(_currentStatus);
      _tabsNeedingReload.add(newStatus);

      // Refresh current list
      await fetchOrdersByStatus(_currentStatus);

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error updating order status: $e");
    }
  }

  Future<void> fetchOrderByUserAndStatus(
      String userId, OrderStatus orderstatus) async {
    try {
      _isLoading = true;
      notifyListeners();
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('orderStatus', isEqualTo: orderstatus.name)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromMap({
                ...doc.data(),
                'orderId': doc.id,
              }))
          .toList();
    } catch (e, s) {
      log("[Order] [fetch by user and status] Error $e");
      log("[Order] [fetch by user and status] Stack $s");
    }

    _isLoading = false;
    notifyListeners();
  }
}
