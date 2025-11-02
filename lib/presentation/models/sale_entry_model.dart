import 'package:cloud_firestore/cloud_firestore.dart';

class SaleEntry {
  final String buyerId;
  final String orderId;
  final String categoryId;
  final double productPrice;
  final int quantity;
  final double totalPrice;
  final Timestamp boughtAt;

  SaleEntry({
    required this.buyerId,
    required this.orderId,
    required this.categoryId,
    required this.productPrice,
    required this.quantity,
    required this.totalPrice,
    required this.boughtAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'orderId': orderId,
      'categoryId': categoryId,
      'productPrice': productPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'boughtAt': boughtAt,
    };
  }

  factory SaleEntry.fromMap(Map<String, dynamic> map) {
    return SaleEntry(
      buyerId: map['buyerId'] ?? '',
      orderId: map['orderId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      productPrice: (map['productPrice'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 1).toInt(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      boughtAt: map['boughtAt'] ?? Timestamp.now(),
    );
  }
}
