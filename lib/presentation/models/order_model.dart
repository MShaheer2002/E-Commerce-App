import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/cartItem_model.dart';

class OrderModel {
  String? orderId;
  final String userId;
  final List<CartItemModel> cartItems; 
  final double totalAmount;
  final Timestamp orderDate;
  final String paymentIntentId; // Stripe payment intent ID
  final String paymentMethod; // Usually 'card'
  final String address;
  final String orderStatus; // 'placed', 'shipped', 'delivered', etc.

  OrderModel({
    this.orderId,
    required this.userId,
    required this.cartItems,
    required this.totalAmount,
    required this.orderDate,
    required this.paymentIntentId,
    required this.paymentMethod,
    required this.address,
    required this.orderStatus,
  });

  /// Converts the object to a Map (for local usage or debugging)
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'cartItems': cartItems.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'paymentIntentId': paymentIntentId,
      'paymentMethod': paymentMethod,
      'address': address,
      'orderStatus': orderStatus,
    };
  }

  /// Converts the object to a JSON-serializable Map (for Firebase)
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'cartItems': cartItems.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate, // Firestore supports Timestamp directly
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
      cartItems: (map['cartItems'] as List<dynamic>? ?? [])
          .map((item) => CartItemModel.fromMap(item))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      orderDate: map['orderDate'] ?? Timestamp.now(),
      paymentIntentId: map['paymentIntentId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'card',
      address: map['address'] ?? '',
      orderStatus: map['orderStatus'] ?? 'placed',
    );
  }
}
