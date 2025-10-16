import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../presentation/models/product_model.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isloading = false;

  List<ProductModel> _productsByCategory = [];
  List<ProductModel> get productsByCategory => _productsByCategory;

  /// Optimized fetch with caching & minimal reads
  Future<void> fetchProductsByCategory(String categoryId) async {
    try {
      isloading = true;
      notifyListeners();
      debugPrint('Fetching products for $categoryId from Firestore 🔥');

      final querySnapshot = await _db
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .get();

      final products = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromMap(data);
      }).toList();
      _productsByCategory = products;
      isloading = false;

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching products by category: $e');
      _productsByCategory = [];
      isloading = false;
      notifyListeners();
    }
  }
}
