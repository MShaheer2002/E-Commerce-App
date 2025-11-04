import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final Timestamp createdAt;
  final String? promoCode;
  final Timestamp? promoCodeEndTime;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
    this.promoCode,
    this.promoCodeEndTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'promoCode': promoCode,
      'promoCodeEndTime': promoCodeEndTime,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      promoCode: map['promoCode'],
      promoCodeEndTime: map['promoCodeEndTime'],
    );
  }
}
