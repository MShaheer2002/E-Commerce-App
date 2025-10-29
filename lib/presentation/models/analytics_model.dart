class AnalyticsModel {
  final DateTime date; // date for daily/weekly/monthly stats
  final double totalSales; // total amount of all successful orders
  final int totalOrders; // number of orders

  AnalyticsModel({
    required this.date,
    required this.totalSales,
    required this.totalOrders,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'totalSales': totalSales,
      'totalOrders': totalOrders,
    };
  }

  factory AnalyticsModel.fromMap(Map<String, dynamic> map) {
    return AnalyticsModel(
      date: DateTime.parse(map['date']),
      totalSales: (map['totalSales'] ?? 0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
    );
  }
}
