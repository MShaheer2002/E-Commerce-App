import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ProductPlug/presentation/models/product_model.dart';

class CartItemModel {
  String? id;
  final ProductModel product;
  final String userId;
  int quantity;
  final double priceAtPurchase;
  final Timestamp addedAt;

  CartItemModel({
    this.id,
    required this.product,
    required this.userId,
    required this.quantity,
    required this.priceAtPurchase,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'userId': userId,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
      // Convert Timestamp → ISO string for JSON safety
      'addedAt': addedAt.toDate().toIso8601String(),
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    Timestamp timestamp;

    // Handle multiple possible formats (Timestamp, DateTime, String)
    final addedAtValue = map['addedAt'];
    if (addedAtValue is Timestamp) {
      timestamp = addedAtValue;
    } else if (addedAtValue is String) {
      timestamp = Timestamp.fromDate(DateTime.parse(addedAtValue));
    } else if (addedAtValue is DateTime) {
      timestamp = Timestamp.fromDate(addedAtValue);
    } else {
      timestamp = Timestamp.now();
    }

    return CartItemModel(
      id: map['id'],
      product:
          ProductModel.fromMap(Map<String, dynamic>.from(map['product'] ?? {})),
      userId: map['userId'] ?? '',
      quantity: map['quantity'] ?? 1,
      priceAtPurchase: (map['priceAtPurchase'] ?? 0).toDouble(),
      addedAt: timestamp,
    );
  }
}
