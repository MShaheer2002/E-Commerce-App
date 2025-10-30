import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/providers/handle_unautharized_access_provider.dart';
import 'package:e_commerce_app/presentation/models/address_model.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckoutProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HandleUnauthorizedAccessProvider _authGuard;
  AddressModel? _addressModel;

  bool orderConfirmed = false;
  String? _userId;
  bool _isloading = false;

  AddressModel? get addressModel => _addressModel;

  bool get loading => _isloading;
  String get userId => _userId ?? '';
  CheckoutProvider(this._authGuard) {
    _userId = _auth.currentUser?.uid;
  }

  Future<void> handlePurchase(OrderModel order) async {
    try {
      final counterRef = _db.collection('counters').doc('orders');
      final ordersRef = _db.collection('orders');

      await _db.runTransaction((transaction) async {
        final counterSnapshot = await transaction.get(counterRef);

        int newOrderNumber = 1;
        if (counterSnapshot.exists) {
          final currentOrderId = counterSnapshot.data()?['currentOrderId'] ?? 0;
          newOrderNumber = currentOrderId + 1;
          transaction.update(counterRef, {'currentOrderId': newOrderNumber});
        } else {
          // ✅ Automatically create collection and doc
          transaction.set(counterRef, {'currentOrderId': 1});
        }

        final newOrderId = 'ORD${newOrderNumber.toString().padLeft(4, '0')}';

        final newOrderDoc = ordersRef.doc(newOrderId);
        transaction.set(
          newOrderDoc,
          order.toJson()..['orderId'] = newOrderId,
        );
      });

      log('✅ Order placed successfully.');
    } catch (e, stack) {
      log('❌ Error placing order: $e');
      log('$stack');
    }
  }
}
