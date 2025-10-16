import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id; // cart item id
  final String productId;
  final String userId;
  final int quantity;
  final double priceAtPurchase;
  final Timestamp addedAt;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.quantity,
    required this.priceAtPurchase,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
      'addedAt': addedAt,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      quantity: map['quantity'] ?? 1,
      priceAtPurchase: (map['priceAtPurchase'] ?? 0).toDouble(),
      addedAt: map['addedAt'] ?? Timestamp.now(),
    );
  }
}
