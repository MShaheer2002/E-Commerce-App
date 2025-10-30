import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/address_model.dart';
import 'package:e_commerce_app/presentation/models/cartItem_model.dart';

enum OrderStatus {
  placed,
  shipped,
  delivered,
  cancelled,
}

class OrderModel {
  String? orderId;
  final String userId;
  final List<CartItemModel> cartItems;
  final double totalAmount;
  final Timestamp orderDate;
  final String paymentIntentId; // Stripe payment intent ID
  final String paymentMethod; // Usually 'card'
  final AddressModel address;
  final OrderStatus orderStatus;

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

  /// ✅ Converts object to a Map (for Firebase/Firestore)
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'cartItems': cartItems.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'paymentIntentId': paymentIntentId,
      'paymentMethod': paymentMethod,
      'address': address.toMap(), // ✅ FIXED HERE
      'orderStatus': orderStatus.name,
    };
  }

  /// ✅ Converts object to a Map for debugging/local use
  Map<String, dynamic> toMap() => toJson();

  /// ✅ Factory for reading from Firestore
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final statusStr = (map['orderStatus'] ?? 'placed').toString();

    return OrderModel(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      cartItems: (map['cartItems'] as List<dynamic>? ?? [])
          .map((item) => CartItemModel.fromMap(item))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      orderDate:
          map['orderDate'] is Timestamp ? map['orderDate'] : Timestamp.now(),
      paymentIntentId: map['paymentIntentId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'card',
      address: AddressModel.fromMap(
        Map<String, dynamic>.from(map['address'] ?? {}),
      ), // ✅ FIXED HERE
      orderStatus: OrderStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => OrderStatus.placed,
      ),
    );
  }
}
