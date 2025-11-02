import 'package:e_commerce_app/presentation/models/sale_entry_model.dart';

class ProductAnalytics {
  final String productId;
  final int totalSales;         // Number of times the product was sold
  final double totalRevenue;    // Total revenue generated
  final int totalAddToFav;      // Number of users who added it to favorites
  final int totalAddToCart;     // Number of users who added it to cart
  final List<SaleEntry> sales;  // List of individual sale entries

  ProductAnalytics({
    required this.productId,
    this.totalSales = 0,
    this.totalRevenue = 0.0,
    this.totalAddToFav = 0,
    this.totalAddToCart = 0,
    this.sales = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'totalAddToFav': totalAddToFav,
      'totalAddToCart': totalAddToCart,
      'sales': sales.map((sale) => sale.toMap()).toList(),
    };
  }

  factory ProductAnalytics.fromMap(Map<String, dynamic> map) {
    return ProductAnalytics(
      productId: map['productId'] ?? '',
      totalSales: map['totalSales'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      totalAddToFav: map['totalAddToFav'] ?? 0,
      totalAddToCart: map['totalAddToCart'] ?? 0,
      sales: map['sales'] != null
          ? List<SaleEntry>.from(
              (map['sales'] as List).map((e) => SaleEntry.fromMap(e)))
          : [],
    );
  }
}
