import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/providers/handle_unautharized_access_provider.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckoutProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HandleUnauthorizedAccessProvider _authGuard;

  bool orderConfirmed = false;
  String? _userId;
  bool _isloading = false;

  bool get loading => _isloading;
  String get userId => _userId ?? '';
  CheckoutProvider(this._authGuard) {
    _userId = _auth.currentUser?.uid;
  }

  void handlePurchase(OrderModel order) {
    if (_isloading) return;

    _isloading = true;
    try {
      _db.collection('orders').doc(_userId).set(order.toJson());
    } catch (e, stack) {
      log('[checkout screen]: $e');
      log('$stack');
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}
