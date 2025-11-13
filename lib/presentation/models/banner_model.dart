import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String? bannerId;
  final String imageUrl;
  final int? position;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    required this.imageUrl,
    this.bannerId,
    this.position,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      imageUrl: json['imageUrl'] ?? '',
      bannerId: json['bannerId'] ?? '',
      position: json['position'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'bannerId': bannerId,
      'position': position,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
