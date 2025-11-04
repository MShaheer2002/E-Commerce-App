import 'package:cloud_firestore/cloud_firestore.dart';

class TaxModel {
  final String id; // Unique identifier (e.g., tax ID or doc ID)
  final String name; // e.g., "Sales Tax", "VAT"
  final double rate; // e.g., 7.5 for 7.5%
  final bool isActive;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  const TaxModel({
    required this.id,
    required this.name,
    required this.rate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rate': rate,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory TaxModel.fromMap(Map<String, dynamic> map) {
    return TaxModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rate: (map['rate'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'],
    );
  }

  /// ✅ Convenience getter for percentage (returns 0.075 for 7.5%)
  double get rateDecimal => rate / 100;

  /// ✅ Apply tax to a subtotal
  double calculateTax(double subtotal) => subtotal * rateDecimal;
}
