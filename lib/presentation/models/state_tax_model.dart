class StateTaxModel {
  final String id;
  final String name;
  final String code;
  final double taxRate;

  StateTaxModel({
    required this.id,
    required this.name,
    required this.code,
    required this.taxRate,
  });

  StateTaxModel copyWith({
    String? id,
    String? name,
    String? code,
    double? taxRate,
  }) {
    return StateTaxModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  factory StateTaxModel.fromJson(Map<String, dynamic> json) {
    return StateTaxModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      taxRate: _parseDouble(json['taxRate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "code": code,
      "taxRate": taxRate,
    };
  }

  /// Safely parse taxRate from int/double/string
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
