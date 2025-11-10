import 'package:cloud_firestore/cloud_firestore.dart';

class TaxModel {
  final String id; // Unique identifier (e.g., tax ID or doc ID)
  final String name; // e.g., "Sales Tax", "VAT"
  final String? description; // Optional description of the tax
  final double rate; // e.g., 7.5 for 7.5%
  final bool isActive;
  final bool isDefault; // If true, this tax is applied by default
  final TaxType type; // Type of tax (percentage or fixed amount)
  final String? applicableRegion; // e.g., "US", "EU", "Global"
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  const TaxModel({
    required this.id,
    required this.name,
    this.description,
    required this.rate,
    this.isActive = true,
    this.isDefault = false,
    this.type = TaxType.percentage,
    this.applicableRegion,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rate': rate,
      'isActive': isActive,
      'isDefault': isDefault,
      'type': type.name,
      'applicableRegion': applicableRegion,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory TaxModel.fromMap(Map<String, dynamic> map) {
    return TaxModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      rate: (map['rate'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? true,
      isDefault: map['isDefault'] ?? false,
      type: TaxType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TaxType.percentage,
      ),
      applicableRegion: map['applicableRegion'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'],
    );
  }

  /// ✅ Convenience getter for percentage (returns 0.075 for 7.5%)
  double get rateDecimal => type == TaxType.percentage ? rate / 100 : rate;

  /// ✅ Apply tax to a subtotal
  double calculateTax(double subtotal) {
    if (type == TaxType.percentage) {
      return subtotal * rateDecimal;
    } else {
      return rate; // Fixed amount
    }
  }

  TaxModel copyWith({
    String? id,
    String? name,
    String? description,
    double? rate,
    bool? isActive,
    bool? isDefault,
    TaxType? type,
    String? applicableRegion,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return TaxModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rate: rate ?? this.rate,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
      applicableRegion: applicableRegion ?? this.applicableRegion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum TaxType {
  percentage, // Tax is a percentage of the subtotal
  fixed, // Tax is a fixed amount
}
