import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String? id;
  final String name;
  final String description;
  final double price;
  final double retailPrice;
  final double? discountPrice;
  final bool isSoldout;
  final String categoryId;
  final List<String> imageUrls;
  final int stock;
  final bool isFeatured;
  final String shippingCharges;
  final Timestamp createdAt;
  final String? promoCode;
  final Timestamp? promoCodeEndTime;
  final String? productLink;
  final String? search_name;

  const ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.retailPrice,
    this.discountPrice,
    required this.isSoldout,
    required this.categoryId,
    required this.imageUrls,
    required this.stock,
    required this.shippingCharges,
    this.isFeatured = false,
    required this.createdAt,
    this.promoCode,
    this.promoCodeEndTime,
    this.productLink,
    required this.search_name,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? retailPrice,
    double? discountPrice,
    bool? isSoldout,
    String? categoryId,
    List<String>? imageUrls,
    String? shippingCharges,
    int? stock,
    bool? isFeatured,
    String? promoCode,
    String? productLink,
    Timestamp? promoCodeEndTime,
    String? search_name,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      retailPrice: retailPrice ?? this.retailPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      isSoldout: isSoldout ?? this.isSoldout,
      categoryId: categoryId ?? this.categoryId,
      imageUrls: imageUrls ?? this.imageUrls,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt,
      productLink: productLink ?? this.productLink,
      promoCode: promoCode ?? this.promoCode,
      promoCodeEndTime: promoCodeEndTime ?? this.promoCodeEndTime,
      search_name: search_name ?? this.search_name,
      shippingCharges: shippingCharges ?? this.shippingCharges,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'retailPrice': retailPrice,
      'discountPrice': discountPrice,
      'isSoldout': isSoldout,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
      'stock': stock,
      'isFeatured': isFeatured,
      'createdAt': createdAt,
      'promoCode': promoCode,
      'shippingCharges': shippingCharges,
      'productLink': productLink,
      'promoCodeEndTime': promoCodeEndTime,
      'search_name': search_name,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      retailPrice: (map['retailPrice'] ?? 0).toDouble(),
      discountPrice: map['discountPrice'] != null
          ? (map['discountPrice']).toDouble()
          : null,
      isSoldout: map['isSoldout'] ?? false,
      shippingCharges: map['shippingCharges'] ?? '0',
      categoryId: map['categoryId'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      stock: map['stock'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      promoCode: map['promoCode'],
      productLink: map['productLink'],
      promoCodeEndTime: map['promoCodeEndTime'],
      search_name: map['search_name'],
    );
  }
}
