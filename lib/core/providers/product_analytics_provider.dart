import 'dart:async';

import 'package:ProductPlug/presentation/models/product_analytics_model.dart';
import 'package:ProductPlug/presentation/models/sale_entry_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProductAnalyticsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to analytics collection
  CollectionReference get _analyticsRef =>
      _firestore.collection('product_analytics');

  // int _dummyCounter = 0;

  /// Create analytics document for new product
  Future<void> createAnalyticsForNewProduct(String productId) async {
    final docRef = _analyticsRef.doc(productId);
    final doc = await docRef.get();

    if (!doc.exists) {
      final analytics = ProductAnalytics(productId: productId);
      await docRef.set(analytics.toMap());
      debugPrint("✅ Analytics created for product: $productId");
    } else {
      debugPrint("⚠️ Analytics already exists for: $productId");
    }
  }

  /// Ensure ProductAnalytics Document Exists
  Future<void> _initializeProduct(String productId) async {
    final docRef = _analyticsRef.doc(productId);
    final doc = await docRef.get();

    if (!doc.exists) {
      final newAnalytics = ProductAnalytics(productId: productId);
      await docRef.set(newAnalytics.toMap());
    }
  }

  /// Increment Total Add to Favorite
  Future<void> incrementAddToFav(String productId) async {
    try {
      await _initializeProduct(productId);
      await _analyticsRef.doc(productId).update({
        'totalAddToFav': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint("⚠️ Failed to increment fav analytics: $e");
    }
  }

  /// Increment Total Add to Cart
  Future<void> incrementAddToCart(String productId) async {
    try {
      await _initializeProduct(productId);
      await _analyticsRef.doc(productId).update({
        'totalAddToCart': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint("⚠️ Failed to increment cart analytics: $e");
    }
  }

  ///  Record a Sale (On Successful Purchase)
  Future<void> recordSale({
    required String productId,
    required String buyerId,
    required String orderId,
    required String categoryId,
    required double productPrice,
    required int quantity,
  }) async {
    await _initializeProduct(productId);

    final double totalPrice = productPrice * quantity;
    final saleEntry = SaleEntry(
      buyerId: buyerId,
      orderId: orderId,
      categoryId: categoryId,
      productPrice: productPrice,
      quantity: quantity,
      totalPrice: totalPrice,
      boughtAt: Timestamp.now(),
    );

    final docRef = _analyticsRef.doc(productId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, ProductAnalytics(productId: productId).toMap());
      }

      transaction.update(docRef, {
        'totalSales': FieldValue.increment(quantity),
        'totalRevenue': FieldValue.increment(totalPrice),
        'sales': FieldValue.arrayUnion([saleEntry.toMap()]),
      });

      unawaited(_firestore.collection("sales_logs").add(saleEntry.toMap()));
    });
  }

  /// Fetch Analytics (for Admin Dashboard)
  Future<ProductAnalytics?> getProductAnalytics(String productId) async {
    final doc = await _analyticsRef.doc(productId).get();
    if (!doc.exists) return null;
    return ProductAnalytics.fromMap(doc.data() as Map<String, dynamic>);
  }
}
