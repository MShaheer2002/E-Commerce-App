import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String productId;
  final Timestamp addedAt;

  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'addedAt': addedAt,
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      addedAt: map['addedAt'] ?? Timestamp.now(),
    );
  }
}
