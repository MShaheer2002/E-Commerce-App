import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/providers/handle_unautharized_access_provider.dart';
import 'package:e_commerce_app/core/providers/product_analytics_provider.dart';
import 'package:e_commerce_app/presentation/models/address_model.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HandleUnauthorizedAccessProvider _authGuard;
  final ProductAnalyticsProvider _analyticsProvider;
  AddressModel? _addressModel;

  bool orderConfirmed = false;
  String? _userId;
  final bool _isloading = false;

  AddressModel? get addressModel => _addressModel;

  bool get loading => _isloading;
  String get userId => _userId ?? '';
  CheckoutProvider(this._authGuard, this._analyticsProvider) {
    _userId = _auth.currentUser?.uid;
  }

  Future<void> _authCheck(BuildContext context) async {
    try {
      final isAuthenticatedUser = await _authGuard.ensureUserAuthenticated();
      if (!isAuthenticatedUser) {
        // Redirect to login if user is not authenticated
        if (context.mounted) {
          context.go('/login');
        }
      }
    } catch (e, stack) {
      log('❌ Error auth: $e');
      log('$stack');
    }
  }

  Future<void> handlePurchase(BuildContext context, OrderModel order) async {
    try {
      _authCheck(context);
      final counterRef = _db.collection('counters').doc('orders');
      final ordersRef = _db.collection('orders');
      String newOrderId = '';
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

        newOrderId = 'ORD${newOrderNumber.toString().padLeft(4, '0')}';

        final newOrderDoc = ordersRef.doc(newOrderId);
        transaction.set(
          newOrderDoc,
          order.toJson()..['orderId'] = newOrderId,
        );
      });

      // After transaction success, record analytics for each product
      for (final cartItem in order.cartItems) {
        final product = cartItem.product;

        unawaited(_analyticsProvider.recordSale(
          productId: product.id ?? '',
          buyerId: order.userId,
          orderId: newOrderId,
          categoryId: product.categoryId,
          productPrice: product.discountPrice ?? product.price,
          quantity: cartItem.quantity,
        ));
      }
      log('✅ Order placed successfully.');
    } catch (e, stack) {
      log('❌ Error placing order: $e');
      log('$stack');
    }
  }
}
