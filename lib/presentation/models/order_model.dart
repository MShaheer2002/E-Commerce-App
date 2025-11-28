import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/address_model.dart';
import 'package:e_commerce_app/presentation/models/cartItem_model.dart';

enum OrderStatus {
  placed,
  shipped,
  delivered,
  cancelled,
}

enum DeliveryPartner {
  fedex,
  ups,
  usps,
  dhl;
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
  final String? trackingNumber;
  final DeliveryPartner? deliveryPartner;
  final OrderStatus orderStatus;

  OrderModel(
      {this.orderId,
      required this.userId,
      required this.cartItems,
      required this.totalAmount,
      required this.orderDate,
      this.trackingNumber,
      this.deliveryPartner,
      required this.paymentIntentId,
      required this.paymentMethod,
      required this.address,
      required this.orderStatus});

  /// ✅ Converts object to a Map (for Firebase/Firestore)
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'cartItems': cartItems.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'trackingNumber': trackingNumber,
      'deliveryPartner': deliveryPartner,
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
    final deliveryStr = map['deliveryPartner']?.toString();
    return OrderModel(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      cartItems: (map['cartItems'] as List<dynamic>? ?? [])
          .map((item) => CartItemModel.fromMap(item))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      orderDate:
          map['orderDate'] is Timestamp ? map['orderDate'] : Timestamp.now(),

      /// FIXED: Convert string → DeliveryPartner enum
      deliveryPartner: deliveryStr == null
          ? null
          : DeliveryPartner.values.firstWhere(
              (e) => e.name == deliveryStr,
              orElse: () => DeliveryPartner.fedex,
            ),
      trackingNumber: map['trackingNumber'] ?? '',
      paymentIntentId: map['paymentIntentId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'card',
      address:
          AddressModel.fromMap(Map<String, dynamic>.from(map['address'] ?? {})),
      orderStatus: OrderStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => OrderStatus.placed,
      ),
    );
  }

  OrderModel copyWith({
    String? orderId,
    String? userId,
    List<CartItemModel>? cartItems,
    double? totalAmount,
    Timestamp? orderDate,
    String? paymentIntentId,
    String? paymentMethod,
    AddressModel? address,
    String? trackingNumber,
    DeliveryPartner? deliveryPartner,
    OrderStatus? orderStatus,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      cartItems: cartItems ?? this.cartItems,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      address: address ?? this.address,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      deliveryPartner: deliveryPartner ?? this.deliveryPartner,
      orderStatus: orderStatus ?? this.orderStatus,
    );
  }
}

/// Convert string → OrderStatus safely
OrderStatus orderStatusFromString(String? value) {
  if (value == null) return OrderStatus.placed;

  return OrderStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => OrderStatus.placed,
  );
}

/// Convert string → DeliveryPartner safely
DeliveryPartner? deliveryPartnerFromString(String? value) {
  if (value == null || value.isEmpty) return null;

  return DeliveryPartner.values.firstWhere(
    (e) => e.name == value,
    orElse: () => DeliveryPartner.fedex,
  );
}
