import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<Map<String, dynamic>> products; // [{productId, quantity, price}]
  final double totalAmount;
  final Timestamp orderDate;
  final String paymentIntentId; // Stripe payment intent ID
  final String paymentMethod; // Usually 'card'
  final String address;
  final String orderStatus; // 'placed', 'shipped', 'delivered', etc.

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.products,
    required this.totalAmount,
    required this.orderDate,
    required this.paymentIntentId,
    required this.paymentMethod,
    required this.address,
    required this.orderStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'products': products,
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'paymentIntentId': paymentIntentId,
      'paymentMethod': paymentMethod,
      'address': address,
      'orderStatus': orderStatus,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      products: List<Map<String, dynamic>>.from(map['products'] ?? []),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      orderDate: map['orderDate'] ?? Timestamp.now(),
      paymentIntentId: map['paymentIntentId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'card',
      address: map['address'] ?? '',
      orderStatus: map['orderStatus'] ?? 'placed',
    );
  }
}
