import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/product_analytics_model.dart';
import 'package:e_commerce_app/presentation/models/sale_entry_model.dart';
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
    await _initializeProduct(productId);
    await _analyticsRef.doc(productId).update({
      'totalAddToFav': FieldValue.increment(1),
    });
  }

  /// Increment Total Add to Cart
  Future<void> incrementAddToCart(String productId) async {
    await _initializeProduct(productId);
    await _analyticsRef.doc(productId).update({
      'totalAddToCart': FieldValue.increment(1),
    });
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
    });
  }

  /// Fetch Analytics (for Admin Dashboard)
  Future<ProductAnalytics?> getProductAnalytics(String productId) async {
    final doc = await _analyticsRef.doc(productId).get();
    if (!doc.exists) return null;
    return ProductAnalytics.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Future<void> dummyAnalyticsData() async {
  //   const productId = 'v8Vs8TWDZx7QR0r1SmEn';
  //   await _initializeProduct(productId);

  //   final List<Map<String, dynamic>> dummySales = [
  //     {
  //       'date': '25 October 2025 at 12:15:24 UTC+5',
  //       'quantity': 2,
  //       'total': 600
  //     },
  //     {
  //       'date': '26 October 2025 at 09:47:10 UTC+5',
  //       'quantity': 1,
  //       'total': 300
  //     },
  //     {
  //       'date': '27 October 2025 at 17:22:33 UTC+5',
  //       'quantity': 4,
  //       'total': 1200
  //     },
  //     {
  //       'date': '28 October 2025 at 14:10:55 UTC+5',
  //       'quantity': 3,
  //       'total': 900
  //     },
  //     {
  //       'date': '29 October 2025 at 18:42:18 UTC+5',
  //       'quantity': 6,
  //       'total': 1800
  //     },
  //     {
  //       'date': '30 October 2025 at 10:33:44 UTC+5',
  //       'quantity': 5,
  //       'total': 1500
  //     },
  //     {
  //       'date': '31 October 2025 at 15:57:01 UTC+5',
  //       'quantity': 7,
  //       'total': 2100
  //     },
  //     {
  //       'date': '1 November 2025 at 11:25:39 UTC+5',
  //       'quantity': 3,
  //       'total': 900
  //     },
  //     {
  //       'date': '2 November 2025 at 13:33:17 UTC+5',
  //       'quantity': 4,
  //       'total': 1200
  //     },
  //   ];

  //   final docRef = _analyticsRef.doc(productId);

  //   final dateFormat = DateFormat("d MMMM yyyy 'at' HH:mm:ss 'UTC+5'");

  //   for (int i = 0; i < dummySales.length; i++) {
  //     final sale = dummySales[i];

  //     // ✅ Parse the date correctly using intl
  //     final parsedDate = dateFormat.parse(sale['date'], true);
  //     final dateWithOffset = parsedDate.add(const Duration(hours: 5));

  //     final quantity = sale['quantity'];
  //     final totalPrice = sale['total'];
  //     final productPrice = totalPrice / quantity;

  //     final saleEntry = SaleEntry(
  //       buyerId: 'dummyBuyer$i',
  //       orderId: 'ORD00$i',
  //       categoryId: 'beverages',
  //       productPrice: productPrice.toDouble(),
  //       quantity: quantity,
  //       totalPrice: totalPrice.toDouble(),
  //       boughtAt: Timestamp.fromDate(dateWithOffset),
  //     );

  //     await _firestore.runTransaction((transaction) async {
  //       final snapshot = await transaction.get(docRef);

  //       if (!snapshot.exists) {
  //         transaction.set(
  //             docRef, ProductAnalytics(productId: productId).toMap());
  //       }

  //       transaction.update(docRef, {
  //         'totalSales': FieldValue.increment(quantity),
  //         'totalRevenue': FieldValue.increment(totalPrice),
  //         'sales': FieldValue.arrayUnion([saleEntry.toMap()]),
  //       });
  //     });
  //   }

  //   debugPrint("✅ Dummy analytics data successfully added for $productId");
  // }

}
