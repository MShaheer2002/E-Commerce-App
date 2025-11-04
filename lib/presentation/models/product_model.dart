import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String? id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final List<String> imageUrls;
  final int stock;
  final bool isFeatured;
  final Timestamp createdAt;
  final String? promoCode;
  final Timestamp? promoCodeEndTime;

  const ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    required this.imageUrls,
    required this.stock,
    this.isFeatured = false,
    required this.createdAt,
    this.promoCode,
    this.promoCodeEndTime,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? categoryId,
    List<String>? imageUrls,
    int? stock,
    bool? isFeatured,
    String? promoCode,
    Timestamp? promoCodeEndTime,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      categoryId: categoryId ?? this.categoryId,
      imageUrls: imageUrls ?? this.imageUrls,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt,
      promoCode: promoCode ?? this.promoCode,
      promoCodeEndTime: promoCodeEndTime ?? this.promoCodeEndTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
      'stock': stock,
      'isFeatured': isFeatured,
      'createdAt': createdAt,
      'promoCode': promoCode,
      'promoCodeEndTime': promoCodeEndTime,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice'] != null
          ? (map['discountPrice']).toDouble()
          : null,
      categoryId: map['categoryId'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      stock: map['stock'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      promoCode: map['promoCode'],
      promoCodeEndTime: map['promoCodeEndTime'],
    );
  }
}
